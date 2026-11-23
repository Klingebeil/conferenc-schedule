# Conference Schedule Template

This project generates printable conference schedules from CSV data using Typst:
- **A3 program**: One portrait page per conference date, with a single-column timeline. Workshops sharing a start time appear side by side.
- **A4 room schedule**: One portrait page per room/date pair that has at least one event.

## Requirements

- Typst 0.15 or a compatible recent version

## Build PDFs

From the repository root:

```sh
mkdir -p dist
typst compile "src/complete-schedule-A3.typ" "dist/conference-program-A3.pdf"
typst compile "src/room-schedule-A4.typ" "dist/room-program-A4.pdf"
```

## Edit the data

Edit `conference-schedule.csv` and `speaker-list.csv`. Keep headers and column order unchanged.

**Format requirements:**
- ISO dates: `YYYY-MM-DD`
- Times: `HH:MM` (24-hour format)
- In the `Speaker` field: use exact `Name Nachname` values from `speaker-list.csv`, join multiple speakers with `|`
- Image paths are relative to `src/`; leave blank to omit speaker images

### conference-schedule.csv columns
| Column | Required | Notes |
|--------|----------|-------|
| `Date` | Yes | ISO format `YYYY-MM-DD` |
| `Starttime` | Yes | `HH:MM` |
| `Endtime` | Yes | `HH:MM` |
| `Type` | Yes | `Talk`, `Workshop`, or `Pause` |
| `Titel` | Yes | Event title |
| `Untertitel` | No | Subtitle |
| `Beschreibung` | No | Short description |
| `Raum` | Yes | Room name |
| `Speaker` | No | Speaker names (pipe-separated if multiple) |

### speaker-list.csv columns
| Column | Required | Notes |
|--------|----------|-------|
| `Name` | Yes | Given name(s) |
| `Nachname` | Yes | Family name(s) |
| `Title` | No | Honorific or academic title |
| `Jobtitel` | No | Role |
| `Arbeitgeber` | No | Organization |
| `Image-path` | No | Path relative to `src/`, e.g. `assets/speaker-images/ada.svg` |

Exact full names are matched as `Name Nachname`. Unmatched names display "Speaker not found"; duplicate full names are reported as errors.

## Customize display

Edit the `template` configuration in the `.typ` files to control what appears:

```
#let template = (
  show-times: true,              // Display event times
  show-room: true,               // Display room name (A3 only)
  show-speakers: true,           // Display speaker names
  show-speaker-images: true,     // Display speaker photos
  show-subtitles: true,          // Display event subtitles
  show-description: true,        // Display event descriptions
)
```

A3 uses all options; A4 sets `show-room: false` by default (since each page is already a specific room).

## Template structure

- `template/vendor/template.typ`: Page layouts, typography, and event card design
- `template/vendor/schedule-data.typ`: CSV loading, validation, speaker resolution, and event sorting
- Entry points (`complete-schedule-A3.typ`, `room-schedule-A4.typ`) filter and present events
