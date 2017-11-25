import logging
import re
from typing import Counter
import numpy as np
import os
from gensim.models import Word2Vec
from keras import Sequential
from keras.layers import Embedding, Conv1D, MaxPooling1D, Flatten, Dense
from keras.models import model_from_json
from keras.preprocessing.sequence import pad_sequences
from keras.preprocessing.text import Tokenizer
from numpy import asarray, zeros
import pickle

from src import config
from src.config import input_length

all_languages = ["Python", "C", "Java", "Scala", "Javascript", "CSS", "C#", "HTML"]


def load_words_from_string(s):
    contents = " ".join(s.splitlines())
    result = re.split(r"[{}()\[\]\'\":.*\s,#=_/\\><;?\-|+]", contents)

    # remove empty elements
    result = [word for word in result if word.strip() != ""]

    return result


def save_vocab_tokenizer(vocab_tokenzier_location, vocab_tokenizer):
    with open(vocab_tokenzier_location, 'wb') as f:
        pickle.dump(vocab_tokenizer, f, protocol=pickle.HIGHEST_PROTOCOL)


def load_vocab_tokenizer(vocab_tokenizer_location):
    with open(vocab_tokenizer_location, 'rb') as f:
        tokenizer = pickle.load(f)
    return tokenizer


def evaluate_saved_data(x_file_name, y_file_name, model):
    x = np.loadtxt(x_file_name)
    y = np.loadtxt(y_file_name)
    loss, accuracy = model.evaluate(x, y, verbose=2)
    print(f"loss: {loss}, accuracy: {accuracy}")


def to_binary_list(i, count):
    result = [0] * count
    result[i] = 1
    return result


def get_lang_sequence(lang):
    for i in range(len(all_languages)):
        if all_languages[i] == lang:
            return to_binary_list(i, len(all_languages))
    raise Exception(f"Language {lang} is not supported.")


def encode_sentence(sentence, vocab_tokenizer):
    encoded_sentence = vocab_tokenizer.texts_to_sequences(sentence.split())
    return [word[0] for word in encoded_sentence if len(word) != 0]


def load_vocab(vocab_location):
    with open(vocab_location) as f:
        words = f.read().splitlines()
    return set(words)


def load_word2vec(word2vec_location):
    result = dict()
    with open(word2vec_location, "r", encoding="utf-8") as f:
        lines = f.readlines()[1:]
    for line in lines:
        parts = line.split()
        result[parts[0]] = asarray(parts[1:], dtype="float32")
    return result


def load_model(model_file_location, weights_file_location):
    with open(model_file_location) as f:
        model = model_from_json(f.read())
    model.load_weights(weights_file_location)
    return model


def build_vocab_tokenizer_from_set(s):
    vocab_tokenizer = Tokenizer(lower=False, filters="")
    vocab_tokenizer.fit_on_texts(s)
    return vocab_tokenizer


def get_files(data_dir):
    result = []
    depth = 0
    for root, sub_folders, files in os.walk(data_dir):
        depth += 1

        # ignore the first loop
        if depth == 1:
            continue

        language = os.path.basename(root)
        result.extend([os.path.join(root, f) for f in files])
        depth += 1
    return result


def load_words_from_file(file_name):
    try:
        with open(file_name, "r") as f:
            contents = f.read()
    except UnicodeDecodeError:
        logging.warning(f"Encountered UnicodeDecodeError, ignore file {file_name}.")
        return []
    return load_words_from_string(contents)


def get_languages(ext_lang_dict):
    languages = set()
    for ext, language in ext_lang_dict.items():
        if type(language) is str:
            languages.update([language])
        elif type(language) is list:
            languages.update(language)
    return languages


def save_model(model, model_file_location, weights_file_location):
    os.makedirs(os.path.dirname(model_file_location), exist_ok=True)
    with open(model_file_location, "w") as f:
        f.write(model.to_json())
    model.save_weights(weights_file_location)


def save_vocabulary(vocabulary, file_location):
    with open(file_location, "w+") as f:
        for word in vocabulary:
            f.write(word + "\n")


def is_in_vocab(word, vocab_tokenizer):
    return word in vocab_tokenizer.word_counts.keys()


def concatenate_qualified_words(words, vocab_tokenizer):
    return " ".join([word for word in words if is_in_vocab(word, vocab_tokenizer)])


def load_sentence_from_file(file_name, vocab_tokenizer):
    words = load_words_from_file(file_name)
    return concatenate_qualified_words(words, vocab_tokenizer)


def load_sentence_from_string(s, vocab_tokenizer):
    words = load_words_from_string(s)
    return concatenate_qualified_words(words, vocab_tokenizer)


def load_encoded_sentence_from_file(file_name, vocab_tokenizer):
    sentence = load_sentence_from_file(file_name, vocab_tokenizer)
    return encode_sentence(sentence, vocab_tokenizer)


def load_encoded_sentence_from_string(s, vocab_tokenizer):
    sentence = load_sentence_from_string(s, vocab_tokenizer)
    return encode_sentence(sentence, vocab_tokenizer)


def load_data(data_dir, vocab_tokenizer):
    files = get_files(data_dir)
    x = []
    y = []
    for f in files:
        language = os.path.dirname(f).split(os.path.sep)[-1]
        x.append(load_encoded_sentence_from_file(f, vocab_tokenizer))
        y.append(get_lang_sequence(language))
    return pad_sequences(x, maxlen=input_length), asarray(y)


def build_vocab(train_data_dir):
    vocabulary = Counter()
    files = get_files(train_data_dir)
    for f in files:
        words = load_words_from_file(f)
        vocabulary.update(words)

    # remove rare words
    min_count = 5
    vocabulary = [word for word, count in vocabulary.items() if count >= min_count]
    return vocabulary


def build_word2vec(train_data_dir, vocab_tokenizer):
    all_words = []
    files = get_files(train_data_dir)
    for f in files:
        words = load_words_from_file(f)
        all_words.append([word for word in words if is_in_vocab(word, vocab_tokenizer)])
    model = Word2Vec(all_words, size=100, window=5, workers=8, min_count=1)
    return {word: model[word] for word in model.wv.index2word}


def get_word2vec_dimension(word2vec):
    first_vector = list(word2vec.values())[0]
    return len(first_vector)


def build_weight_matrix(vocab_tokenizer, word2vec):
    vocab_size = len(vocab_tokenizer.word_index) + 1
    word2vec_dimension = get_word2vec_dimension(word2vec)
    weight_matrix = zeros((vocab_size, word2vec_dimension))
    for word, index in vocab_tokenizer.word_index.items():
        weight_matrix[index] = word2vec[word]
    return weight_matrix


def build_model(train_data_dir, vocab_tokenizer, word2vec):
    weight_matrix = build_weight_matrix(vocab_tokenizer, word2vec)

    # build the embedding layer
    input_dim = len(vocab_tokenizer.word_index) + 1
    output_dim = get_word2vec_dimension(word2vec)
    x_train, y_train = load_data(train_data_dir, vocab_tokenizer)

    embedding_layer = Embedding(input_dim, output_dim, weights=[weight_matrix], input_length=input_length,
                                trainable=False)
    model = Sequential()
    model.add(embedding_layer)
    model.add(Conv1D(filters=128, kernel_size=5, activation="relu"))
    model.add(MaxPooling1D(pool_size=2))
    model.add(Flatten())
    model.add(Dense(len(all_languages), activation="sigmoid"))
    logging.info(model.summary())
    model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
    model.fit(x_train, y_train, epochs=10, verbose=2)
    return model


def evaluate_model(test_data_dir, vocab_tokenizer, model):
    x_test, y_test = load_data(test_data_dir, vocab_tokenizer)
    loss, acc = model.evaluate(x_test, y_test, verbose=0)
    logging.info('Test Accuracy: %f' % (acc * 100))


def build_and_save_vocab_tokenizer(train_data_dir, vocab_tokenizer_location):
    vocab = build_vocab(train_data_dir)
    vocab_tokenizer = build_vocab_tokenizer_from_set(vocab)
    save_vocab_tokenizer(vocab_tokenizer_location, vocab_tokenizer)
    return vocab_tokenizer


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    vocab_tokenizer = build_and_save_vocab_tokenizer(config.train_data_dir, config.vocab_tokenizer_location)
    word2vec = build_word2vec(config.train_data_dir, vocab_tokenizer)

    model = build_model(config.train_data_dir, vocab_tokenizer, word2vec)
    evaluate_model(config.test_data_dir, vocab_tokenizer, model)

    save_model(model, config.model_file_location, config.weights_file_location)
