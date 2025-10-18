"""
Applet: Focus Todo
Summary: Displays your current focus task and a progress bar of total vs. completed tasks
Description: Fetches a JSON structure from a local server and shows the next unfinished checklist item along with progress. Great for tracking your daily work list from a markdown file.
"""

load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")

# Configurable mock data (can replace with http.get in production)
dataa = {
    "status": "ok",
    "total": 8,
    "completed": 3,
    "next": "Tell sean about the currency bug sometime in the near furture hello"
}
blue="#3399FF"
red="#FF0000"
green="#fff"
done_color="#00FF5A"
remaining_color="#404040"

DEFAULT_TASKS_URL="http://focus-api.k8s"



def safe_text(text, color):
    return render.Marquee(
        width=64,
        height=20,
        child=render.Text(
            content=text,
            color=color
        ),
        scroll_direction1="vertical",
        offset_start=5,
        offset_end=64,
        delay= 5,
    )

def wrap_text(text, color):
    return render.WrappedText(
        width=60,
        content=text,
        color=color,
        font="tom-thumb"
    )

def render_completed(completed, total):
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
                content="TODO"
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

    components = []
    components.append(render_completed(completed, total))
    components.append(
        render.Padding(
            child=wrap_text(data["next"], "#FFD700"),
            pad=(0,2,0,0)
        )
    )
    return root(render.Column(components))
