#!/usr/bin/env python3
"""Minimal SeaDex best-release watcher.

The YAML file is both configuration and persistent state.  The script never
manages downloads; it only compares SeaDex's current `isBest` torrent set
against the last saved set and notifies a Discord webhook when that set
changes.
"""

from __future__ import annotations

import json
import os
import re
import sys
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

import yaml


DEFAULT_API_URL = "https://releases.moe/api/collections/entries/records"
DEFAULT_CONFIG = Path("./config.yaml")
DEFAULT_WEBHOOK_ENV = "SEADEX_DISCORD_WEBHOOK"

# Only ask SeaDex for fields the watcher actually needs.  `expand=trs` is
# limited to the tracked AniList entry by the `alID` filter, and `fields`
# trims the expanded torrent payload further.
ENTRY_FIELDS = ",".join(
    [
        "id",
        "alID",
        "url",
        "expand.trs.id",
        "expand.trs.isBest",
        "expand.trs.releaseGroup",
        "expand.trs.tracker",
        "expand.trs.url",
        "expand.trs.infoHash",
        "expand.trs.updated",
    ]
)


def die(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def parse_timestamp(value: str | None) -> datetime | None:
    if value in (None, ""):
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as exc:
        raise ValueError(f"invalid ISO-8601 timestamp: {value!r}") from exc
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def parse_duration(value: str | int | float | None) -> timedelta:
    """Parse a compact duration such as 6h, 30m, 1d, or 0."""
    if value is None:
        return timedelta(0)
    if isinstance(value, (int, float)):
        return timedelta(seconds=float(value))

    match = re.fullmatch(r"\s*(\d+(?:\.\d+)?)\s*([smhd])\s*", str(value))
    if not match:
        raise ValueError(
            f"invalid min_check_interval {value!r}; use e.g. 30m, 6h, 1d, or 0"
        )

    amount = float(match.group(1))
    unit = match.group(2)
    seconds = {
        "s": amount,
        "m": amount * 60,
        "h": amount * 60 * 60,
        "d": amount * 24 * 60 * 60,
    }[unit]
    return timedelta(seconds=seconds)


def http_json(url: str, *, method: str = "GET", body: dict | None = None) -> dict:
    headers = {"User-Agent": "seadex-watch/1.0", "Accept": "application/json"}
    payload = None

    if body is not None:
        headers["Content-Type"] = "application/json"
        payload = json.dumps(body).encode("utf-8")

    request = Request(url, method=method, headers=headers, data=payload)

    try:
        with urlopen(request, timeout=30) as response:
            return json.load(response)
    except HTTPError as exc:
        try:
            detail = exc.read().decode("utf-8", errors="replace")
        except Exception:
            detail = str(exc)
        raise RuntimeError(f"HTTP {exc.code} from {url}: {detail}") from exc
    except URLError as exc:
        raise RuntimeError(f"request failed for {url}: {exc.reason}") from exc


def save_yaml_atomic(path: Path, config: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.NamedTemporaryFile(
        "w",
        encoding="utf-8",
        dir=path.parent,
        prefix=f".{path.name}.",
        suffix=".tmp",
        delete=False,
    ) as tmp:
        yaml.safe_dump(
            config,
            tmp,
            sort_keys=False,
            allow_unicode=True,
            default_flow_style=False,
        )
        temp_name = tmp.name

    os.replace(temp_name, path)


def load_yaml(path: Path) -> dict:
    try:
        with path.open("r", encoding="utf-8") as handle:
            config = yaml.safe_load(handle)
    except FileNotFoundError:
        die(f"config file does not exist: {path}")
    except yaml.YAMLError as exc:
        die(f"could not parse YAML: {exc}")

    if not isinstance(config, dict):
        die("top-level YAML value must be a mapping")

    config.setdefault("last_checked", None)
    config.setdefault("min_check_interval", "6h")
    config.setdefault("api_url", DEFAULT_API_URL)
    config.setdefault("webhook_env", DEFAULT_WEBHOOK_ENV)
    config.setdefault("series", [])

    if not isinstance(config["series"], list):
        die("series must be a list")

    return config


def should_check(config: dict) -> bool:
    last_checked = parse_timestamp(config.get("last_checked"))
    if last_checked is None:
        return True

    interval = parse_duration(config.get("min_check_interval"))
    age = now_utc() - last_checked
    return age >= interval


def fetch_entry(api_url: str, anilist_id: int) -> dict:
    params = {
        "filter": f"alID={int(anilist_id)}",
        "perPage": "1",
        "skipTotal": "true",
        "expand": "trs",
        "fields": ENTRY_FIELDS,
    }
    url = f"{api_url}?{urlencode(params)}"
    data = http_json(url)

    items = data.get("items", [])
    if not items:
        raise RuntimeError(f"no SeaDex entry found for AniList ID {anilist_id}")
    return items[0]


def normalize_best(entry: dict) -> list[dict]:
    expanded = entry.get("expand", {})
    torrents = expanded.get("trs", [])
    best = []

    for torrent in torrents:
        if not torrent.get("isBest", False):
            continue

        # Keep the stable identity plus enough display/context information for
        # a useful notification.  `updated` is intentionally included so a
        # SeaDex record being materially updated counts as a change.
        best.append(
            {
                "id": torrent["id"],
                "release_group": torrent.get("releaseGroup", ""),
                "tracker": torrent.get("tracker", ""),
                "url": torrent.get("url", ""),
                "info_hash": torrent.get("infoHash"),
                "updated": torrent.get("updated"),
            }
        )

    best.sort(key=lambda item: item["id"])
    return best


def release_set(value: list[dict] | None) -> dict[str, dict]:
    if not value:
        return {}
    return {item["id"]: item for item in value}


def format_release(release: dict) -> str:
    group = release.get("release_group") or "Unknown group"
    tracker = release.get("tracker") or "Unknown tracker"
    return f"**{group}** ({tracker})\n{release.get('url', '')}".strip()


def format_release_list(releases: list[dict]) -> str:
    if not releases:
        return "*(none)*"
    return "\n\n".join(format_release(release) for release in releases)


def webhook_url(config: dict) -> str:
    env_name = config.get("webhook_env", DEFAULT_WEBHOOK_ENV)
    value = os.environ.get(env_name)
    if not value:
        raise RuntimeError(f"environment variable {env_name!r} is not set")
    return value


def send_discord(webhook: str, content: str) -> None:
    request = Request(
        webhook,
        method="POST",
        headers={
            "User-Agent": "seadex-watch/1.0",
            "Content-Type": "application/json",
        },
        data=json.dumps({"content": content}).encode("utf-8"),
    )

    try:
        with urlopen(request, timeout=30) as response:
            if response.status >= 300:
                raise RuntimeError(f"Discord returned HTTP {response.status}")
    except HTTPError as exc:
        raise RuntimeError(f"Discord webhook failed with HTTP {exc.code}") from exc
    except URLError as exc:
        raise RuntimeError(f"Discord webhook request failed: {exc.reason}") from exc


def build_initial_notification(
    series: dict,
    entry: dict,
    best: list[dict],
) -> str:
    """Build the notification for the first observation when no release is watched."""
    name = series["name"]

    return "\n".join(
        [
            f"**{name} has best release information.**",
            "",
            "**Current best release(s):**",
            format_release_list(best),
            "",
            f"https://releases.moe/{entry.get("alID", "")}",
        ]
    )


def build_notification(
    series: dict,
    entry: dict,
    old_best: list[dict],
    new_best: list[dict],
) -> str:
    name = series["name"]
    watching = series.get("watching")
    watching_id = watching.get("id") if isinstance(watching, dict) else None
    new_by_id = release_set(new_best)
    current_still_best = watching_id is not None and watching_id in new_by_id

    if watching_id is not None:
        if current_still_best:
            title = f"**{name} has a new best release. Your release is still marked best.**"
        else:
            title = f"**{name} has a new best release replacing your current release.**"
    else:
        title = f"**{name} has a new best release.**"

    parts = [title]

    if watching_id is not None:
        watching_release = next(
            (release for release in old_best if release["id"] == watching_id),
            None,
        )
        if watching_release is None and current_still_best:
            watching_release = new_by_id[watching_id]

        if watching_release is not None:
            parts.extend([
                "",
                "**Your current release:**",
                format_release(watching_release),
            ])

        if not current_still_best:
            parts.extend(["", "Your current release is no longer marked best."])

    old_ids = {release["id"] for release in old_best}
    new_releases = [release for release in new_best if release["id"] not in old_ids]

    if not new_releases:
        # This covers metadata updates to an existing best record.
        new_releases = new_best

    parts.extend([
        "",
        "**New/updated best release(s):**",
        format_release_list(new_releases),
        "",
        f"https://releases.moe/{entry.get("alID", "")}",
    ])

    return "\n".join(parts)


def main() -> int:
    config_path = Path(os.environ.get("SEADEX_CONFIG", DEFAULT_CONFIG))
    config = load_yaml(config_path)

    try:
        if not should_check(config):
            print("skipping: minimum check interval has not elapsed")
            return 0

        webhook = webhook_url(config)
        api_url = config["api_url"]
    except (ValueError, RuntimeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    had_errors = False
    state_changed = False

    for series in config["series"]:
        name = series.get("name")
        anilist_id = series.get("anilist_id")

        if not name or not isinstance(anilist_id, int):
            print(
                f"skipping invalid series entry: {series!r}",
                file=sys.stderr,
            )
            had_errors = True
            continue

        try:
            entry = fetch_entry(api_url, anilist_id)
            new_best = normalize_best(entry)
            old_best = series.get("seadex_best")

            # First successful observation:
            # - If the user has a specific release configured, silently establish
            #   the baseline. We don't know that anything changed yet.
            # - If watching.id is null, the user explicitly wants notifications
            #   about the best set itself, so report the initial best set too.
            if old_best is None:
                watching = series.get("watching")
                watching_id = (
                    watching.get("id")
                    if isinstance(watching, dict)
                    else None
                )

                if watching_id is None:
                    notification = build_initial_notification(
                        series,
                        entry,
                        new_best,
                    )
                    print(f"{name}: sending initial best-release notification")
                    send_discord(webhook, notification)
                    print(
                        f"{name}: initialized with "
                        f"{len(new_best)} best release(s); notification sent"
                    )
                else:
                    print(
                        f"{name}: initialized with "
                        f"{len(new_best)} best release(s)"
                    )

                series["seadex_best"] = new_best
                state_changed = True
                continue

            if old_best == new_best:
                print(f"{name}: unchanged")
                continue

            notification = build_notification(
                series,
                entry,
                old_best,
                new_best,
            )
            send_discord(webhook, notification)

            series["seadex_best"] = new_best
            state_changed = True
            print(f"{name}: best release set changed; notification sent")

        except Exception as exc:
            had_errors = True
            print(f"{name}: ERROR: {exc}", file=sys.stderr)

    # Only advance the global timestamp if every tracked entry completed.
    # That means a transient SeaDex failure is retried on the next invocation.
    if not had_errors:
        config["last_checked"] = now_utc().isoformat().replace("+00:00", "Z")
        state_changed = True

    if state_changed:
        try:
            save_yaml_atomic(config_path, config)
        except OSError as exc:
            print(f"error: failed to save {config_path}: {exc}", file=sys.stderr)
            return 1

    return 1 if had_errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
