#import "template/vendor/template-MIF.typ": a4-program, schedule-page, schedule-row, colors, page-style, card-style
#import "template/vendor/schedule-data.typ": load-schedule, get-day-tag

#let conference-schedule = csv("conference-schedule.csv")
#let speaker-list = csv("speaker-list.csv")
#let conference-name = "Conference Name"

#let template = (
  show-times: true,
  show-room: true,
  show-speakers: true,
  show-subtitles: true,
  show-description: true,
  show-speaker-images: true,
)

#let schedule = load-schedule(conference-schedule, speaker-list)

#set page(
  width: 2000pt,
  height: 1125pt,
  flipped: false,
  margin: (x: 1.5cm, y: 1.25cm),
  // background: image("assets/Speaker Screen Vorlage Gesamt.pdf", page: 1)
)
  
#set text(font: page-style.font, size: 50pt, fill: colors.ink)
#set par(leading: page-style.a4.leading)

#let talk-events = schedule.events.filter(event => event.type != "Pause")

#for (page-index, event) in talk-events.enumerate() [
  #if page-index > 0 [
    #pagebreak()
  ]
  #let type-index = if event.type == "Workshop" {
    1
  } else if event.type == "Talk" {
    2
  } else {
    3
  }

  #set page(
    background: context {
      image(
        "assets/Speaker Screen Vorlage Gesamt.pdf", 
        page: type-index,
        fit: "cover",
        )
    },
  )

  #box(
    width: 80%,
    height: 690pt
  )[
  
  #box(
    inset: 15pt,
    stroke: 2pt,
    radius: 40pt,
  )[#h(10pt) #text(size: 35pt, event.type) #h(10pt)]
  
  #par(leading: 0.9em)[
  #text(font: "PP Formula", size: 200pt, fill: colors.ink, event.title)]
  // #schedule-row((event,), template: template)
  ]
  #v(0pt)
  #box(
    width: 85%,
    height: 300pt
  )[
    #let cols = (1fr, 1fr)
    #let row = (1fr)

    #if int(event.speakers.len()) > 2 [
      #let cols = (1fr, 1fr)
      #let row = (1fr, 1fr)
    ] 
    #grid(
      columns: cols,
      rows: row,
      column-gutter: 10pt,
      row-gutter: 10pt,
      ..event.speakers.enumerate().map(item => {
        let (index, speaker) = item
        let speaker-columns = if template.show-speaker-images {
          (100pt, 1fr)
        } else {
          (1fr,)
        }
        grid(
          columns: speaker-columns,
          column-gutter: 10pt,
          if template.show-speaker-images [
            #image(speaker.image-path)
          ],
          [
            #set par(leading: 0.2em)
            #text(size: 48pt, weight: "bold")[#speaker.full-name]
            #if speaker.title != "" [
              #text(size: 32pt)[#speaker.title]
            ]
            #linebreak()
            #if speaker.job-title != "" [
              #text(size: 32pt)[#speaker.job-title]
            ]
            #if speaker.employer != "" [
              #text(size: 32pt)[(#speaker.employer)]
            ]
          ],
        )
      })
    )
  ]
  #pagebreak(weak: true)
]