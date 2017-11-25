import numpy as np
from keras.preprocessing.sequence import pad_sequences
from src import config
from src.config import input_length
from src.neural_network_trainer import load_model, \
    load_vocab_tokenizer, load_encoded_sentence_from_string, all_languages

vocab_tokenizer = load_vocab_tokenizer(config.vocab_tokenizer_location)


def to_language(binary_list):
    i = np.argmax(binary_list)
    return all_languages[i]


def get_neural_network_input(code):
    encoded_sentence = load_encoded_sentence_from_string(code, vocab_tokenizer)
    return pad_sequences([encoded_sentence], maxlen=input_length)


def detect(code, model=None):
    if model is None:
        model = load_model(config.model_file_location, config.weights_file_location)
    y_proba = model.predict(get_neural_network_input(code))
    return to_language(y_proba)


if __name__ == "__main__":
    code = """
def test():
    print("something")
"""
    print(detect(code))
