from matplotlib import pyplot as plt
import pandas as pd
import seaborn as sns
from shiny import App, Inputs, Outputs, Session, render, ui

attendance = pd.read_csv("allLogs.csv")



app_ui = ui.page_fluid(
    ui.input_selectize(
    "var", "Select variable",
    choices= attendance["course"].unique().tolist()
    ),
    ui.input_checkbox('sessionSplit', "Split by Session Type", value = False, width = None),
    ui.output_plot("p",width='100%', height='700px'),
)

def server(input: Inputs, output: Outputs, session: Session):

    @render.plot
    def p():
        course = attendance[attendance['course'] == input.var()]
        #course['First join'] = [pd.to_datetime(x[:11]) for x in course['First join']]

        firstJoinExpanded = []
        #course['First join'] = [x[:11] for x in course['First join']]
        for x in course['First join']:
            if type(x) != str:
                firstJoinExpanded.append(None)
            else:
                firstJoinExpanded.append(x[:11])
        course['First join'] = firstJoinExpanded
        #print(attendance["course"].unique())
        print(course)
        
        fig, axes = plt.subplots(ncols=1, nrows=1, figsize=(40, 1))
        fig.subplots_adjust(bottom=0.8)
        #fig.subplots_adjust( left=None, bottom=None,  right=None, top=None, wspace=None, hspace=None)
        if(input.sessionSplit()):
            count = sns.countplot(x='First join',data=course,ax=axes, hue="sessionType")
            sns.move_legend(axes, "upper left", bbox_to_anchor=(1, 1))
        else:
            count = sns.countplot(x='First join',data=course,ax=axes)
        
        count.tick_params(axis='x', rotation=90)
        fig.tight_layout()
        return fig

app = App(app_ui, server)
