# Conference schedule template

This project generates a printable A3 conference program and A4 room schedules from CSV data with Typst.

## Requirements

- Typst 0.15 or a compatible recent version.

## Build PDFs

Run these commands from the repository root:

```sh
mkdir -p dist
typst compile "src/complete-schedule-A3.typ" "dist/conference-program-A3.pdf"
typst compile "src/room-schedule-A4.typ" "dist/room-program-A4.pdf"
```

The A3 program has one portrait page per conference date and follows a single-column timeline; workshops sharing a start time are grouped side by side. The A4 file has one portrait page for each room/date pair that has at least one event.

## Edit the data

Edit `conference-schedule.csv` and `speaker-list.csv` in this directory. Keep their headers and column order unchanged. The expected formats, optional fields, speaker matching behavior, and error handling are documented in the project specification one directory above this README.

Use ISO dates (`YYYY-MM-DD`) and 24-hour local times (`HH:MM`). In the `Speaker` field, use exact `Name Nachname` values from the speaker list, joining multiple speakers with `|`. Image paths are relative to `src/`; blank paths are supported. The sample intentionally includes a speaker name without a match to demonstrate the visible fallback.

## Customize the design

Edit `template/vendor/template.typ` to change the conference name and the `colors`, `page-style`, `speaker-style`, `card-style`, and `schedule-style` settings near the top. The separate talk, workshop, and pause blocks currently share an event card, but can be customized independently.

The shared `template/vendor/schedule-data.typ` loads and validates the CSVs, resolves speakers, and sorts events. The A3 entry point groups events by start time; the A4 entry point selects room/date pages. Both pass the resulting events to the shared presentation blocks.
