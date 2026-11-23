#let conference-name = "Conference Name"

#let template = (
  show-times: true,
  show-room: true,
  show-speakers: true,
  show-subtitles: true,
  show-description: true,
  show-speaker-images: true,
)

#let colors = (
  ink: rgb("#182333"),
  muted: rgb("#526174"),
  paper: rgb("#FFFFFF"),
  accent: rgb("#000000"),
  talk: rgb("#ffffff"),
  workshop: rgb("#ffffff"),
  pause: rgb("#ffffff"),
)

#let page-style = (
  a3: (margin: (x: 1.4cm, y: 1.25cm), text-size: 10pt, leading: 0.65em),
  a4: (margin: (x: 1.5cm, y: 1.4cm), text-size: 11pt, leading: 0.7em),
  font: "Helvetica Neue",
)

#let speaker-style = (
  image-size: 2.5em,
  image-radius: 100%,
  image-column: 3em,
  column-gutter: 0.6em,
  row-gutter: 0.25em,
  spacing: 0.35em,
)

#let card-style = (
  inset: 0.8em,
  accent-width: 3pt,
  time-column: 5.4em,
  column-gutter: 0.8em,
  time-spacing: 0.5em,
  type-size: 0.76em,
  title-size: 1.5em,
  subtitle-size: 0.8em,
  description-size: 0.8em,
  text-size: 1em,
  room-size: 0.8em,
  title-spacing: 0.2em,
  description-spacing: 0.2em,
  detail-spacing: 0.2em,
)

#let schedule-style = (
  column-gutter: 0.8em,
  row-spacing: 0em,
  heading-size: 2em,
  date-size: 1.25em,
  heading-spacing: 0.8em,
)

#let a3-program(body) = {
  set page(
    paper: "a3",
    flipped: false,
    margin: page-style.a3.margin,
    fill: colors.paper,
  )
  set text(font: page-style.font, size: page-style.a3.text-size, fill: colors.ink)
  set par(leading: page-style.a3.leading)
  body
}

#let a4-program(body) = {
  set page(
    paper: "a4",
    flipped: false,
    margin: page-style.a4.margin,
    fill: colors.paper,
  )
  set text(font: page-style.font, size: page-style.a4.text-size, fill: colors.ink)
  set par(leading: page-style.a4.leading)
  body
}

#let speaker-portrait(speaker) = {
  let size = speaker-style.image-size
  if speaker.image-path != "" {
    box(width: size, height: size, clip:true, radius: speaker-style.image-radius)[
      #image("../../" + speaker.image-path, width: size, height: size, fit: "cover")
    ]
  }
}

#let speaker-line(speakers, template: template) = {
  for (index, speaker) in speakers.enumerate() [
    #let columns = if template.show-speaker-images {
      (speaker-style.image-column, 1fr)
    } else {
      (1fr,)
    }
    #let gutter = if template.show-speaker-images {
      speaker-style.column-gutter
    } else {
      0em
    }
    #grid(
      columns: columns,
      column-gutter: gutter,
      row-gutter: speaker-style.row-gutter,
      if template.show-speaker-images [
        #place(top+left, speaker-portrait(speaker))
      ],
      [
        #strong(speaker.full-name)
        #if speaker.title != "" [ · #speaker.title]
        #linebreak()
        #if speaker.job-title != "" [#speaker.job-title]
        #if speaker.job-title != "" and speaker.employer != "" [ · ]
        #if speaker.employer != "" [#speaker.employer]
      ],
    )
    #if index < speakers.len() - 1 [#v(speaker-style.spacing)]
  ]
}

#let event-card(event, tint, template: template) = {
  block(
    width: 100%,
    fill: tint,
    inset: card-style.inset,
  )[
    #let columns = if template.show-times {
      (card-style.time-column, 1fr)
    } else {
      (1fr,)
    }
    #let gutter = if template.show-times {
      card-style.column-gutter
    } else {
      0em
    }
    #grid(
      columns: columns,
      column-gutter: gutter,
      if template.show-times [
        #stack(
          spacing: card-style.time-spacing,
          text(size: card-style.text-size, weight: "bold")[#event.starttime],
          text(size: card-style.text-size, fill: colors.muted)[#event.endtime],
        )
      ],
      [
        #text(size: card-style.type-size, weight: "bold", fill: colors.accent)[#upper(event.type)]
        #v(card-style.title-spacing)
        #text(size: card-style.title-size, weight: "bold")[#event.title]
        #if template.show-subtitles and event.subtitle != "" [
          #linebreak()
          #text(size: card-style.subtitle-size, fill: colors.muted)[#event.subtitle]
        ]
        #if template.show-description and event.description != "" [
          #v(card-style.description-spacing)
          #text(size: card-style.description-size)[#event.description]
        ]
        #if template.show-room [
          #v(card-style.detail-spacing)
          #text(size: card-style.subtitle-size, weight: "bold", fill: colors.muted)[#event.room]
        ]
        #if template.show-speakers [
          #v(card-style.detail-spacing)
          #speaker-line(event.speakers, template: template)
        ]
      ],
    )
  ]
}

#let talk-block(event, template: template) = event-card(event, colors.talk, template: template)
#let workshop-block(event, template: template) = event-card(event, colors.workshop, template: template)
#let pause-block(event, template: template) = event-card(event, colors.pause, template: template)

#let schedule-event(event, template: template) = {
  if event.type == "Workshop" {
    workshop-block(event, template: template)
  } else if event.type == "Pause" {
    pause-block(event, template: template)
  } else {
    talk-block(event, template: template)
  }
}

#let schedule-row(events, template: template) = [
  #if events.len() == 1 [
    #schedule-event(events.first(), template: template)
  ] else if events.len() > 1 [
    #grid(
      columns: events.len(),
      column-gutter: schedule-style.column-gutter,
      row-gutter: 0.5em,
      ..events.map(event => schedule-event(event, template: template)),
    )
  ]
  #if events.len() > 0 [#v(schedule-style.row-spacing)]
]

#let schedule-page(date, first: false, body) = [
  #if not first [#pagebreak()]
  #body
]
