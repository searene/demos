import random


class Node:
    def __init__(self, data):

        # all the data that is held by this node
        self.data = data

        # left child node
        self.left = None

        # right child node
        self.right = None

        # category if the current node is a leaf node
        self.category = None

        # a tuple: (row, column), representing the point where we split the data
        # into the left/right node
        self.split_point = None


def build_model(train_data, n_trees, max_depth, min_size, n_features, n_sample_rate):
    trees = []
    for i in range(n_trees):
        random.shuffle(train_data)
        n_samples = int(len(train_data) * n_sample_rate)
        tree = build_tree(train_data[: n_samples], 1, max_depth, min_size, n_features)
        trees.append(tree)
    return trees


def predict_with_single_tree(tree, row):
    if tree.category is not None:
        return tree.category
    x, y = tree.split_point
    split_value = tree.data[x][y]
    if row[y] <= split_value:
        return predict_with_single_tree(tree.left, row)
    else:
        return predict_with_single_tree(tree.right, row)


def predict(trees, row):
    prediction = []
    for tree in trees:
        prediction.append(predict_with_single_tree(tree, row))
    return max(set(prediction), key=prediction.count)


def get_most_common_category(data):
    categories = [row[-1] for row in data]
    return max(set(categories), key=categories.count)


def build_tree(train_data, depth, max_depth, min_size, n_features):
    root = Node(train_data)
    x, y = get_split_point(train_data, n_features)
    left_group, right_group = split(train_data, x, y)
    if len(left_group) == 0 or len(right_group) == 0 or depth >= max_depth:
        root.category = get_most_common_category(left_group + right_group)
    else:
        root.split_point = (x, y)
        if len(left_group) < min_size:
            root.left = Node(left_group)
            root.left.category = get_most_common_category(left_group)
        else:
            root.left = build_tree(left_group, depth + 1, max_depth, min_size, n_features)

        if len(right_group) < min_size:
            root.right = Node(right_group)
            root.right.category = get_most_common_category(right_group)
        else:
            root.right = build_tree(right_group, depth + 1, max_depth, min_size, n_features)
    return root


def get_features(n_selected_features, n_total_features):
    features = [i for i in range(n_total_features)]
    random.shuffle(features)
    return features[:n_selected_features]


def get_categories(data):
    return set([row[-1] for row in data])


def get_split_point(data, n_features):
    n_total_features = len(data[0]) - 1
    features = get_features(n_features, n_total_features)
    categories = get_categories(data)
    x, y, gini_index = None, None, None
    for index in range(len(data)):
        for feature in features:
            left, right = split(data, index, feature)
            current_gini_index = get_gini_index(left, right, categories)
            if gini_index is None or current_gini_index < gini_index:
                x, y, gini_index = index, feature, current_gini_index
    return x, y


def get_gini_index(left, right, categories):
    gini_index = 0
    for group in left, right:
        if len(group) == 0:
            continue
        score = 0
        for category in categories:
            p = [row[-1] for row in group].count(category) / len(group)
            score += p * p
        gini_index += (1 - score) * (len(group) / len(left + right))
    return gini_index


def split(data, x, y):
    split_value = data[x][y]
    left, right = [], []
    for row in data:
        if row[y] <= split_value:
            left.append(row)
        else:
            right.append(row)
    return left, right