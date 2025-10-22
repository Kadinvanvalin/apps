"""
Applet: Focus Todo
Summary: Displays your current focus task and a progress bar of total vs. completed tasks
Description: Fetches a JSON structure from a local server and shows the next unfinished checklist item along with progress. Great for tracking your daily work list from a markdown file.
"""

load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("animation.star", "animation")
load("encoding/base64.star", "base64")
load("random.star", "random")
load("time.star", "time")
load("humanize.star", "humanize")
DEFAULT_TASKS_URL = "http://focus-api.k8s"
#DEFAULT_TASKS_URL="http://localhost:8080"

# Configurable mock data (can replace with http.get in production)
BTC_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABEAAAARCAYAAAA7bUf6AAAAlklEQVQ4T2NkwAH+H2T/jy7FaP+
TEZtyDEG4Zi0TTPXXzoDF0A1DMQRsADbN6MZdO4NiENwQbAbERh1lWLzMmgFGo5iFZBDYEFwuwG
sISCPUIKyGgDRjAyBXYXMNIz5XgDQga8TpLboYgux8DO/AwoUuLiEqTLBFMcmxQ7V0gssgklIsL
AYozjsoBoE45OZi5DRBSnkCAMLhlPBiQGHlAAAAAElFTkSuQmCC
""")
THINGS_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAwBQTFRFR3BMJHTpJnXqJHPoJ3XrJHPpJXTpJnTqJHPoJnXqNHPQI3PoJHTpI3PoI3PoJHPoJnTnJnXqJHTpJHPpJnXqJXTpJHPoJHTpJHTpJHTpI3PoJHPpJHPpI3PoI3PpJXToJXTpJHTpJHTpI3TpI3PoJHTpJXTpJnTnI3TpI3TpI3PoI3PoI3PoJHTpJHPoJHTpJHTpJHPpJHTpJHTpJHTpLHTfJXTpI3ToJHPoJHTpJHTpJHTpI3TpJHPoJXTpJHTmJnLo////JHPovsHJN0FJ/f////7/JHPmInTo///9I3LnNkBINj5H/P7/JHPqInHkvsDIIHPn+f3/KXjkJnLp6/X9NUJJvsLH/P//I3Llv8PLudL63uv+VJDpcqXxPILo/P/+zuH+/v/9pML18/b5OEBJ//3/j7f3OEJKInPrHm7lOkJJIHLqvcHG9fj75efrI3TnP0dPPERLJnPmSozoXJfnHnLmMXvkIHPl/P3+2NvftL7SxMbM9/v+OEFHRExTJXTq+f//MzxDNn7lM37pN0FH8vr/PYTnIXHmqbvXKHfqa6LoSFBWzM/TUFheI3Lqvtb4I3TkanF3XWRq8vT5SYnk0N/4R4jp+vv8+fr7ztHV7vH0L3rp6e77favxvsHNcHZ87/j+TFRbYmlwf6zpn7feW5Tpqcn3Lnfk29/i4OTnbqHq1uP50eT8irbzVZPskpidKXTjkrPluNL16u7xLXjoQ4Xn6PH9IXDplLrxt8/yosX2QYLgp6yxJ3boxtv4l52jWWBmxcrO4e792un9LnjgT47qgomOgabYmb7tbqLxeqnrOYDowMTIfYOIiI6U6Ovu0dbag6/qtru/oqesnaKom7/1nr7xVVxjucHPVJDj1dndrLG3r832jZOYYZrq3+v6h7LvlLDXsre8uL7FbZ3hMDhAZ5zrI3TsdHqA5Onv2Ob5f4WMYZPdeqfwnrPQv8bKo7fUrrS5eX+GeKfmosLud6Hh7PD2q8fvusHIhKriYZLYeH2DkbjpibDkKnbaLeOxZwAAAAF0Uk5TAEDm2GYAAAABYktHRACIBR1IAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH6QoWDwU0lcK3xQAAAJVJREFUGNNjYMANmKEAixCyMDMzFlHmY5snQMGuY3DBd45w8A5DcPZFJMFLULE/+Y6X4IIPHR1TgGKTZjk6PoQLbnJ03Lth9ssrQNU74YI7HR1nHMhYMBNF8DrIxDurQOR1uGAywknJcMFlE15XgkQqX09YxozkzU0rgWATsjeB4JszEJxAE5x64tGjE1NxBRP+QEYHAGTFQ3Nt+YqLAAAAAElFTkSuQmCC
""")
def get_schema():
    return schema.Schema(
        version="1",
        fields=[
            schema.Dropdown(
                id="app",
                name="App",
                desc="Select which App to display",
                icon="brush",
                default="TOMATO",
                options=[
                    schema.Option(
                        display="Focus",
                        value="FOCUS",
                    ),
                    schema.Option(
                        display="Reminder",
                        value="REMINDER",
                    ),
                    schema.Option(
                        display="timer",
                        value="TOMATO",
                    ),
                    schema.Option(
                        display="aphorism",
                        value="APHORISM",
                    ),
                    schema.Option(
                        display="things",
                        value="THINGS",
                    ),
                ],
            ),
            schema.Text(
                id="reminder",
                name="What to remind you of",
                desc="What to remind you of",
                icon="cog",
            ),
            schema.Text(
                id="reminder_tag",
                name="Tag Reminder",
                desc="",
                icon="cog",
            ),

        ]
    )


dataa = {
    "status": "ok",
    "total": 8,
    "completed": 3,
    "percent": 38,
    "next": "Tell sean about the currency bug sometime in the near furture hello",
    "last_updated": "2025-10-18T20:52:16.723Z",
    "age_hours": 3.01151222222222
}
blue = "#3399FF"
red = "#FF0000"
green = "#fff"
done_color = "#00FF5A"
remaining_color = "#404040"
# CONFIGURED_APP="FOCUS"
# CONFIGURED_APP="REMINDERd"

def main(config):
    app = config.str("app", "THINGS")
    if app == "THINGS":
        return render_things(config)
    if app == "REMINDER":
        return render_reminder(config)
    elif app == "APHORISM":
            return render_reminder_api(config)
    elif app == "FOCUS":
        return render_focus(config)
    elif app == "TOMATO":
        return render_timer(config)
    else:
        return root(render.Row(
            children=[
                safe_text("NO APP SELECTED", red),

            ]
        ))

def render_things(config):
    # "updated_at":"2025-10-22T09:44:29-05:00"
    tasks_url = config.str("tasks_url") or DEFAULT_TASKS_URL
    resp = http.get(tasks_url + "/things")
    data = resp.json()
    print(data)
    updated_at = time.parse_time(data['updated_at'])
    icon = render.Image(src  = THINGS_ICON)
    count =  render.WrappedText(
        width=40,
        content="inbox: " +str(data['count']) + "updated at: " + humanize.time(updated_at),
        height=32,
        color=blue,
        font="tom-thumb"
    )
    return  render.Root(render.Row(children = [icon,count]))

def render_timer(config):
    return render.Root(render.Image(src = BTC_ICON),)

def safe_text(text, color):
    return render.Marquee(
        width=64,
        height=20,
        child=render.Text(
            content=text,
            color=color
        ),
        scroll_direction="vertical",
        offset_start=5,
        offset_end=64,
        delay=5,
    )


def wrap_text(text, color):
    return render.WrappedText(
        width=60,
        content=text,
        height=200,
        color=color,
        font="tom-thumb"
    )


def render_completed(completed, total, age_hours):
    count = render.Row(
        children=[
            render.Text(
                color="#000FFF",
                font="tom-thumb",
                content=str(completed)
            ),
            render.Text(
                color=blue,
                font="tom-thumb",
                content="/" + str(total)
            )
        ])

    return render.Row(
        expanded=True,
        main_align="space_between",
        cross_align="end",
        children=[
            render.PieChart(
                colors=[done_color, remaining_color],
                weights=[completed, total],
                diameter=8,
            ),
            render.Text(
                color="#FFF",
                font="tom-thumb",
                content=str(age_hours) + " H"
            ),
            count
        ]
    )


def root(child):
    return render.Root(
        render.Padding(
            child=child,
            pad=(0, 0, 0, 0)
        )
    )




def render_reminder(config):
    text = config.str("reminder", "Null Check")
    tag = config.str("reminder_tag", "Code Quality")
    return root(
        render.Column(
            main_align="start",
            cross_align="start",
            children=[
                render.Box(
                    child=render.WrappedText(
                        content=tag,
                        width=60,
                        color="#000",
                    ),
                    width=64,
                    height=12,
                    color=blue),
                render.Text(text, color="#fa0",)
            ]
        )
    )



def render_reminder_api(config):
    text = config.str("reminder", "Null Check")
    tag = config.str("reminder_tag", "Code Quality")
    reminder_tag_color = config.str("reminder_tag_color", blue)

    tasks_url = config.str("tasks_url") or DEFAULT_TASKS_URL
    resp = http.get(tasks_url + "/reminder")
    data = resp.json()

    # if data["status"] != "ok":
    #     return root(render.Row(
    #         children=[
    #             safe_text("[!!] Git Sync Error", red),
    #             safe_text("Check SSH key.", red)
    #         ]
    #         )
    #     )
    num = random.number(0,  len(data))
    reminder_text = data[num]["text"]

    return root(
        render.Column(
            main_align="start",
            cross_align="start",
            children=[
                render.Box(
                    child=render.WrappedText(
                        content=reminder_text,
                        width=60,
                        linespacing=1,
                        color="#000",
                        font="CG-pixel-4x5-mono"
                    ),
                    width=64,
                    height=32,
                    color="#FFF"),
                # render.WrappedText(reminder_text, font="tom-thumb", color="#fa0",)
            ]
        )
    )



def render_focus(config):
    # Code to execute if no other pattern matches (default case)
    tasks_url = config.str("tasks_url") or DEFAULT_TASKS_URL
    resp = http.get(tasks_url + "/focus", )
    data = resp.json()

    if data["status"] != "ok":
        return root(render.Row(
            children=[
                safe_text("[!!] Git Sync Error", red),
                safe_text("Check SSH key.", red)
            ]
        )
        )

    completed = int(data["completed"])
    total = int(data["total"])
    age_hours = int(data["age_hours"])
    components = []
    components.append(render_completed(completed, total, age_hours))
    components.append(
        render.Padding(
            child=wrap_text(data["next"], "#FFD700"),
            pad=(0, 2, 0, 0)
        )
    )
    return root(render.Column(components))
    # return root(animation.Transformation(
    #     child=render.Column(components),
    #     duration=100,
    #     delay=0,
    #     origin=animation.Origin(0.5, 0.5),
    #     direction="normal",
    #     fill_mode="forwards",
    #     keyframes=[
    #         animation.Keyframe(
    #             percentage=0.0,
    #             transforms=[animation.Translate(0.0, 0.0)],
    #
    #         ),
    #         animation.Keyframe(
    #             percentage=0.3,
    #             transforms=[animation.Translate(0.0, -10.0)],
    #         ),
    #         animation.Keyframe(
    #             percentage=1.0,
    #             transforms=[animation.Translate(0.0, -10.0)],
    #         ),
    #     ],
    # ))
