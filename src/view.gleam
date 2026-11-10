import formal/form.{type Form}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import model.{type Message, type Model}
import pyramid.{type Point, type Pyramid, unfold_pyramid}

pub fn view(model: Model) -> Element(Message) {
  html.main([], [
    html.div([], [point_count_control(model), form_view(model.state)]),
    html.div([attr.class("output")], case model.output {
      None -> [html.text("no input")]
      Some(pyramid) ->
        pyramid
        |> unfold_pyramid
        |> list.map(fn(ps) { [point_view(ps.0), point_view(ps.1)] })
        |> list.flatten
    }),
  ])
}

fn point_view(p: Point) -> Element(Message) {
  let x = p.x |> float.to_precision(2) |> float.to_string
  let y = p.y |> float.to_precision(2) |> float.to_string
  html.div([], [
    html.text("(" <> x <> ", " <> y <> ")"),
  ])
}

const max_count = 10

const min_count = 3

fn point_count_control(model: Model) -> Element(Message) {
  let count = model.count

  html.div([attr.class("point-control")], [
    html.button(
      [
        attr.class("btn-remove-point"),
        event.on_click(model.UserClickedRemovePoint),
        case count <= min_count {
          True -> attr.style("visibility", "hidden")
          False -> attr.none()
        },
      ],
      [html.text("-")],
    ),
    html.span([attr.class("point-control-label")], [
      html.text(int.to_string(count)),
    ]),
    html.button(
      [
        attr.class("btn-add-point"),
        event.on_click(model.UserClickedAddPoint),
        case count >= max_count {
          True -> attr.style("visibility", "hidden")
          False -> attr.none()
        },
      ],
      [html.text("+")],
    ),
  ])
}

fn form_view(state: Form(Pyramid)) -> Element(Message) {
  let points =
    list.zip(
      form.field_values(state, "point-x"),
      form.field_values(state, "point-y"),
    )

  let apex = #(
    form.field_value(state, "apex-x"),
    form.field_value(state, "apex-y"),
    form.field_value(state, "apex-h"),
  )

  html.form(
    [
      attr.class("form"),
      event.on_submit(model.UserClickedCalculate),
      // event.on_reset(UserClickedReset),
    ],
    [
      html.fieldset([], [
        html.legend([], [html.text("Base points:")]),
        html.div([], list.index_map(points, fn(p, i) { point_input(p, i) })),
      ]),

      html.fieldset([], [
        html.legend([], [html.text("Apex:")]),
        apex_input(apex),
      ]),
      html.div([attr.class("buttons")], [
        html.button([attr.class("btn-reset"), attr.type_("reset")], [
          html.text("Reset"),
        ]),
        html.button([attr.class("btn-calculate"), attr.type_("submit")], [
          html.text("Calcuale"),
        ]),
      ]),
    ],
  )
}

fn point_input(point: #(String, String), index: Int) -> Element(Message) {
  let n = int.to_string(index + 1)
  html.fieldset([attr.class("point")], [
    html.legend([], [html.text("Point " <> n <> ":")]),
    field("point-x", label: "x", value: point.0),
    field("point-y", label: "y", value: point.1),
  ])
}

fn apex_input(apex: #(String, String, String)) -> Element(Message) {
  html.div([attr.class("apex")], [
    field("apex-x", label: "x", value: apex.0),
    field("apex-y", label: "y", value: apex.1),
    field("apex-h", label: "h", value: apex.2),
  ])
}

fn field(
  name: String,
  value value: String,
  label label: String,
) -> Element(Message) {
  html.div([attr.class("field")], [
    html.label([], [
      html.span([attr.class("label-text")], [html.text(label)]),
      html.input([
        attr.type_("text"),
        attr.autocomplete("off"),
        attr.inputmode("decimal"),
        attr.name(name),
        attr.value(value),
      ]),
    ]),
  ])
}
