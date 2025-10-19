"""
Applet: Focus Todo
Summary: Displays your current focus task and a progress bar of total vs. completed tasks
Description: Fetches a JSON structure from a local server and shows the next unfinished checklist item along with progress. Great for tracking your daily work list from a markdown file.
"""

load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("animation.star", "animation")
# Configurable mock data (can replace with http.get in production)
dataa = {
    "status": "ok",
    "total": 8,
    "completed": 3,
    "percent": 38,
    "next": "Tell sean about the currency bug sometime in the near furture hello",
    "last_updated": "2025-10-18T20:52:16.723Z",
    "age_hours": 3.01151222222222
}
blue="#3399FF"
red="#FF0000"
green="#fff"
done_color="#00FF5A"
remaining_color="#404040"
# CONFIGURED_APP="FOCUS"
# CONFIGURED_APP="REMINDERd"
DEFAULT_TASKS_URL="http://focus-api.k8s"
#DEFAULT_TASKS_URL="http://localhost:8080"


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
        delay= 5,
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
    count= render.Row(
        children=[
            render.Text(
                color="#000FFF",
                font="tom-thumb",
                content=str(completed)
            ),
            render.Text(
                color=blue,
                font="tom-thumb",
                content= "/" + str(total)
            )
        ])

    return render.Row(
        expanded=True,
        main_align="space_between",
        cross_align="end",
        children=[
            render.PieChart(
                colors = [ done_color, remaining_color],
                weights  = [ completed, total ],
                diameter = 8,
            ),
            render.Text(
                color="#FFF",
                font="tom-thumb",
                content= str(age_hours) + " H"
            ),
            count
        ]
    )
def root(child):
    return render.Root(
        render.Padding(
            child=child,
            pad=(2,1,2,1)
        )
    )

    # Main rendering function
def main(config):
    app = config.str("app", "REMINDER")

    if app == "REMINDER":
        return render_reminder(config)
    elif app == "FOCUS":
        return render_focus(config)
    else:
        return root(render.Row(
            children=[
                safe_text("NO APP SELECTED", red),

            ]
        ))

def render_reminder(config):
    return root(

        render.Column(
            main_align="start",
            cross_align="start",
            children=[
                render.Box(
                    child=render.WrappedText(
                        content="Code Quality",
                        width=60,
                        color="#fa0",
                    ),
                    width=64,
                    height=12, color="#a00"),

        render.Text("Check for Null",
        color="#fa0",
        )
    ]
    )

    )
    # return root(render.Column(
    #     children=[
    #         safe_text("Code Quality:", blue),
    #         render.Marquee(
    #             width=64,
    #             # height=20,
    #             child=render.Text(
    #                 content="Check for Null",
    #                 color=red
    #             ),
    #             # scroll_direction="vertical",
    #             offset_start=5,
    #             offset_end=64,
    #             # delay= 0,
    #         )
    #     ],
    # )
    # )
#return render.Root(
    #     child = render.Box(
    #         render.Row(
    #             expanded = True,  # Use as much horizontal space as possible
    #             main_align = "space_evenly",  # Controls horizontal alignment
    #             cross_align = "center",  # Controls vertical alignment
    #             children = [
    #                 render.Marquee(
    #                     width = 50,
    #                     offset_start = 49,
    #                     align = "center",
    #                     child = render.Text(
    #                         content = content,
    #                         font = font,
    #                         color = color,
    #                     ),
    #                 ),
    #             ],
    #         ),
    #     ),
    # )


def render_focus(config):
# Code to execute if no other pattern matches (default case)
    tasks_url = config.str("tasks_url") or DEFAULT_TASKS_URL
    resp = http.get(tasks_url+"/focus", )
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
            pad=(0,2,0,0)
        )
    )

    return root(animation.Transformation(
        child = render.Column(components),
        duration = 100,
        delay = 0,
        origin = animation.Origin(0.5, 0.5),
        direction = "normal",
        fill_mode = "forwards",
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [animation.Translate(0.0, 0.0)],

            ),
            animation.Keyframe(
                percentage = 0.3,
                transforms = [animation.Translate(0.0, -10.0)],
            ),
            animation.Keyframe(
                percentage = 1.0,
                transforms = [animation.Translate(0.0, -10.0)],
            ),
        ],
    ))



