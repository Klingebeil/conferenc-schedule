---
aliases:
  - Conference Schedule Typst Template
START DATE: 2026-11-20
END DATE:
STATUS: In progress
tags:
  - project
  - typst
---
# Conference Schedule Typst Template

## Goal

Build a flexible, maintainable Typst project that creates printable conference schedules from CSV data:

- A multi-page A3 portrait program, with one page per conference day.
- A multi-page A4 portrait room program, with one page per room and conference day.

The MVP supports multiple conference days, multiple rooms, talks, workshops, breaks, and speakers. The A3 program uses a single-column schedule; workshops with the same start time appear together in a multi-column row. All other events occupy the full schedule width.

## Project structure

```text
src/
  assets/
    speaker-images/
  template/
    vendor/
      template.typ
      schedule-data.typ
  complete-schedule-A3.typ
  room-schedule-A4.typ
  conference-schedule.csv
  speaker-list.csv
  README.md
```

Generated PDFs should be written to `dist/`.

## Input data

Both CSV files use UTF-8, a comma as the column separator, and a header row. Quote any field containing a comma, quote, or line break according to standard CSV rules.

### `conference-schedule.csv`

Columns must appear in this order:

| Column | Format / meaning |
| --- | --- |
| `Date` | Required conference date in ISO format `YYYY-MM-DD`. |
| `Starttime` | Required 24-hour time, `HH:MM`. |
| `Endtime` | Required 24-hour time, `HH:MM`. |
| `Type` | `Talk`, `Workshop`, or `Pause`. |
| `Titel` | Required event title. |
| `Untertitel` | Optional subtitle. |
| `Beschreibung` | Optional short description. |
| `Raum` | Required room name. |
| `Speaker` | Optional exact full names, joined with `|` (pipe). Names must match `Name Nachname` in the speaker list. |

Use one row per event and order events by date, start time, and room for easy editing. The templates sort events by date/time when rendering. Times are local conference times; overnight events are not supported in the MVP.

### `speaker-list.csv`

Columns must appear in this order:

| Column | Format / meaning |
| --- | --- |
| `Name` | Speaker's given name(s). |
| `Nachname` | Speaker's family name(s). |
| `Title` | Optional honorific or academic title. |
| `Jobtitel` | Optional role. |
| `Arbeitgeber` | Optional employer. |
| `Image-path` | Optional path relative to `src/`, for example `assets/speaker-images/ada.svg`. |

The exact full name used to match a schedule speaker is `Name Nachname`. If a name has no match, the schedule prints an explicit “Speaker not found” label; duplicate full names are reported as ambiguous. Empty optional fields and image paths are allowed.

## Template design

`template/vendor/template.typ` owns conference branding, typography, page styles, and reusable event/speaker blocks. Keep styles and spacing easy to adjust, with relative typographic sizing where practical.

`template/vendor/schedule-data.typ` owns CSV decoding, field validation, and speaker matching shared by both outputs. The two schedule entry points select and group the data and populate the blocks defined in `template.typ`; they should not duplicate parsing logic or define typography, spacing, page styles, or grids.

Use flexible grids and content blocks, never Typst tables. The A3 schedule is a single-column timeline except for concurrent workshops, which share a row. Keep typography clear and avoid assumptions about unusually long titles, descriptions, or names.

## Error handling and MVP behavior

- Fail compilation with a clear message when required columns, dates, times, event types, or room/title values are invalid.
- Treat empty subtitle, description, speaker, speaker metadata, and image path as optional.
- Display a clear label for unmatched or ambiguous speaker names; do not silently substitute another person.
- An empty image path omits the portrait and retains the speaker text. Non-empty image paths must resolve to readable files; Typst reports an error for a missing or invalid asset.
- The MVP uses A3 portrait for the all-room program and A4 portrait for room/day pages.

## Build and verification

From the project root, compile both entry points:

```sh
mkdir -p dist
typst compile "src/complete-schedule-A3.typ" "dist/conference-program-A3.pdf"
typst compile "src/room-schedule-A4.typ" "dist/room-program-A4.pdf"
```

The example data covers multiple days, rooms, event types, concurrent workshops, multiple speakers, optional fields, and speaker images. Verify that the A3 PDF has one page per date and the A4 PDF has one page per room/date combination.
