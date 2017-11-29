import random
import numpy as np
import pandas as pd
from math import sqrt

from random_forest import build_model, predict


class CrossValidationSplitter:
    def __init__(self, data, k_fold):
        self.data = data
        self.k_fold = k_fold
        self.n_iteration = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.n_iteration >= self.k_fold:
            raise StopIteration
        self.n_iteration += 1
        return self.__load_data()

    def __load_data(self):
        n_train_data = (1 / self.k_fold) * len(self.data)
        data_copy = self.data[:]
        train_data = []
        while len(train_data) < n_train_data:
            train_data.append(self.__pop_random_row(data_copy))
        test_data = data_copy
        return train_data, test_data

    def __pop_random_row(self, data):
        random.shuffle(data)
        return data[0]


def split_data(data, rate):
    random.shuffle(data)
    n_train_data = int(len(data) * rate)
    return data[: n_train_data], data[n_train_data:]


def calculate_accuracy(model, validate_data):
    n_total = 0
    n_correct = 0
    predicted_categories = [predict(model, row[:-1]) for row in validate_data]
    correct_categories = [row[-1] for row in validate_data]
    for predicted_category, correct_category in zip(predicted_categories, correct_categories):
        n_total += 1
        if predicted_category == correct_category:
            n_correct += 1
    return n_correct / n_total


df = pd.read_csv('resources/sonar.all-data.csv', header=None)
data = df.values.tolist()
train_data_all, test_data = split_data(data, 0.9)

for n_tree in [1, 3, 10]:
    accuracies = []
    cross_validation_splitter = CrossValidationSplitter(train_data_all, 5)
    model = None
    for train_data, validate_data in cross_validation_splitter:
        n_features = int(sqrt(len(train_data[0]) - 1))
        model = build_model(
            train_data=train_data,
            n_trees=n_tree,
            max_depth=5,
            min_size=1,
            n_features=n_features,
            n_sample_rate=0.9
        )
        accuracies.append(calculate_accuracy(model, validate_data))
    print("Average cross validation accuracy for {} trees: {}".format(n_tree, np.mean(accuracies)))
    print("Test accuracy for {} trees: {}".format(n_tree, calculate_accuracy(model, test_data)))