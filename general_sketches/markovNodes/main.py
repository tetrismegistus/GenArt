import nltk
import markovify
from nltk.tokenize import sent_tokenize, word_tokenize

import networkx as nx
from networkx.readwrite import graphml


with open("poem.txt", 'r') as f:
    text = f.read()

#print(text)
#tokens = word_tokenize(text)
#print(tokens)

text_model = markovify.Text(text)

# Get the state dictionary
state_dict = text_model.chain.model

# Create a directed graph representing the Markov chain
graph = nx.DiGraph()
for source_state, next_states in state_dict.items():

    for dest_state, prob in next_states.items():
        print(dest_state, prob)
        print(source_state, dest_state)
        graph.add_edge(' '.join(source_state), dest_state, weight=prob)

# Export the graph to an XML file
graphml.write_graphml(graph, "markov_chain.xml")