import markovify
import graphviz

graph = graphviz.Digraph('finite_state_machine')
graph.attr(rankdir='LR')

# Load the text from a file
with open("output4.txt", encoding='utf-8') as f:
    text = f.read()

# Build the Markov chain model
text_model = markovify.Text(text)
# Prime the model with a word
prime_word = "stone"


# Get the state dictionary
state_dict = text_model.chain.model

# Filter states that start with the prime word
filtered_states = {k: v for k, v in state_dict.items() if k[0] == prime_word}


# Add nodes and edges to the graph
for state, next_states in filtered_states.items():
    for next_state, weight in next_states.items():
        graph.edge(' '.join(state), ' '.join(next_state), label=str(weight))

# Render the graph to a PNG file
graph.render(filename='markov_chain', cleanup=True, format="png")