import matplotlib.pyplot as plt
import scipy.io
import os
import ctypes
import numpy as np
import seaborn as sns
import pandas as pd

cwd = os.getcwd()
isSave = True

STUDY = 'brain'
if STUDY == 'heart':
    res_folder = 'Results/york/'
    y_min_time = 0.0
    y_max_time = 0.06
    y_min_acc = 0.0 # 0.65
    y_max_acc = 1.00
elif STUDY == 'brain':
    res_folder = 'Results/braintumor/'
    y_min_time = 0.0
    y_max_time = 0.20
    y_min_acc = 0.60 # 0.60
    y_max_acc = 1.00
else:
    ctypes.windll.user32.MessageBoxW(None, u"Choose an organ correctly", u"Error", 0)

mat_files = []
timing_data = []
accuracy_data = []
num_slices = []
placement_fails = []
accuracy_errors = []
for file in os.listdir(res_folder):
    if file.endswith(".mat"):
        data = scipy.io.loadmat(res_folder + file)
        data = data['results']
        range = data.shape[0] - 2

        temp_timing_data = data[0:range, -2]
        temp_accuracy_data = data[0:range, -1]
        temp_num_slices = data[-1, 0]
        temp_placement_errors = data[-1, 1]
        temp_accuracy_errors = data[-1, 2]

        timing_data.append(temp_timing_data)
        accuracy_data.append(temp_accuracy_data)
        num_slices.append(temp_num_slices)
        placement_fails.append(temp_placement_errors)
        accuracy_errors.append(temp_accuracy_errors)

        mat_files.append(file)
        print(os.path.join(res_folder, file))

# Gather all the data
list_of_names = ['8-4-2', '12-6-3', '16-8-4', '20-10-5', 'Region-growing']
# placement_errors_df = pd.DataFrame(data=[placement_errors], columns = list_of_names)
# accuracy_errors_df = pd.DataFrame(data=[accuracy_errors], columns = list_of_names)
placement_fails_df = pd.DataFrame({list_of_names[0]:[placement_fails[3]],
                                   list_of_names[1]:[placement_fails[0]],
                                   list_of_names[2]:[placement_fails[1]],
                                   list_of_names[3]:[placement_fails[2]],
                                   list_of_names[4]:[placement_fails[4]]})
accuracy_errors_df = pd.DataFrame({list_of_names[0]:[accuracy_errors[3]],
                                   list_of_names[1]:[accuracy_errors[0]],
                                   list_of_names[2]:[accuracy_errors[1]],
                                   list_of_names[3]:[accuracy_errors[2]],
                                   list_of_names[4]:[accuracy_errors[4]]})
accuracy_to_plot = [accuracy_data[3], accuracy_data[0], accuracy_data[1], accuracy_data[2], accuracy_data[4]]
timing_to_plot = [timing_data[3], timing_data[0], timing_data[1], timing_data[2], timing_data[4]]

# Boxplot drawing function
def draw_boxplot(data, y_min, y_max, y_label):
    FONTSIZE = 22
    csfont = {'fontname':'Times New Roman'}
    fig = plt.figure(1, figsize=(16, 9),
                      dpi=150,
                      tight_layout=True,
                      frameon=True,
                      facecolor='w',
                      edgecolor='k')
    ax = fig.add_subplot(111)
    plt.xticks(fontsize = FONTSIZE, **csfont)
    plt.yticks(fontsize = FONTSIZE, **csfont)
    ax.set_ylim([y_min, y_max])
    ax.set_xlabel('Square size', fontsize=FONTSIZE, **csfont)
    ax.set_ylabel(y_label, fontsize=FONTSIZE, **csfont)
    boxprops= dict(facecolor='white', linestyle='-', linewidth=1.0, color='blue')
    whiskerprops = dict(linestyle='-', linewidth=1.0, color='blue')
    meanprops = dict(linestyle='--', linewidth=1.0, color='green')
    medianprops = dict(linestyle='-', linewidth=1.0, color='red')
    capprops = dict(linestyle='-', linewidth=1.0, color='blue')
    flierprops = dict(color='red', markeredgecolor='red')
    bp = ax.boxplot(data,
                    sym='+',
                    vert=True,
                    whis=1.5,
                    widths = 0.75,
                    patch_artist=True,
                    boxprops=boxprops,
                    capprops=capprops,
                    whiskerprops=whiskerprops,
                    flierprops=flierprops,
                    medianprops=medianprops,
                    showmeans=True,
                    meanline=True,
                    meanprops=meanprops)
    ax.grid(color='black', linestyle='--', axis='both', linewidth=0.5, alpha = 0.6)
    plt.xticks([1, 2, 3, 4, 5], ['8-4-2', '12-6-3', '16-8-4', '20-10-5', 'Region-growing'])
    plt.setp(ax.spines.values(), color='black', alpha = 0.6)
    ax.relim()
    ax.autoscale_view()
    plt.show()
    if isSave == True:
        name = str(y_label) + '_' + STUDY + '.png'
        fig.savefig(name, dpi=300, transparent=False, bbox_inches='tight')

# # Low accuracy errors drawing function
def draw_factorplot(data, y_label):
    sns.set_style("whitegrid",
                  {
                  'axes.edgecolor': '0.6',
                  "ytick.major.size": 0.1,
                  "ytick.minor.size": 0.025,
                  'grid.linestyle': '--',
                  'grid.color': '0.7'
                  })
    FONTSIZE = 22
    csfont = {'fontname': 'Times New Roman'}
    g = sns.factorplot(data=data,
                       palette="BuPu",
                       size=6,
                       aspect=1.5,
                       kind="bar",
                       alpha=0.75,
                       order=list_of_names)
    ax = plt.gca()
    g.set_xlabels('Square size', fontsize=FONTSIZE, **csfont)
    g.set_ylabels(str(y_label), fontsize=FONTSIZE, **csfont)
    plt.xticks(fontsize=FONTSIZE, **csfont)
    plt.yticks(fontsize=FONTSIZE, **csfont)
    # plt.subplots_adjust(left=0.047, bottom=0.094, right=0.991, top=0.981, wspace=0.2, hspace=0.2)
    plt.subplots_adjust(top = 0.981,
                        bottom = 0.095,
                        left = 0.047,
                        right = 0.991,
                        hspace = 0.2,
                        wspace = 0.2)
    for p in ax.patches:
        ax.text(p.get_x() + p.get_width() / 2., p.get_height(), '%d' % int(p.get_height()),
                fontsize=FONTSIZE, color='black', **csfont,  ha='center', va='bottom')
    plt.show()
    if isSave == True:
        name = str(y_label) + '_' + STUDY + '.png'
        g.savefig(name, dpi=300, transparent=False, bbox_inches='tight')

# draw_factorplot(accuracy_errors_df, 'Low accuracy cases')
# draw_factorplot(placement_fails_df, 'Placement fails')
draw_boxplot(accuracy_to_plot, y_min_acc, y_max_acc, 'Accuracy')
# draw_boxplot(timing_to_plot, y_min_time, y_max_time, 'Processing time')

print('Done!')