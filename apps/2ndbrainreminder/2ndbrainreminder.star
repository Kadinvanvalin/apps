"""
Applet: Focus Todo
Summary: Displays your current focus task and a progress bar of total vs. completed tasks
Description: Fetches a JSON structure from a local server and shows the next unfinished checklist item along with progress. Great for tracking your daily work list from a markdown file.
"""

load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")

load("animation.star", "animation")



def main(config):
    return render.Root(
        animation.Transformation(
        child = render.Box(render.Circle(diameter = 6, color = "#0f0")),
        duration = 100,
        delay = 0,
        origin = animation.Origin(0.5, 0.5),
        direction = "alternate",
        fill_mode = "forwards",
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [animation.Rotate(0), animation.Translate(-10, 0), animation.Rotate(0)],
                curve = "ease_in_out",
            ),
            animation.Keyframe(
                percentage = 1.0,
                transforms = [animation.Rotate(360), animation.Translate(-10, 0), animation.Rotate(-360)],
            ),
        ],
    ))

