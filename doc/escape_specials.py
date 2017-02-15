with open('param.tex', 'r') as f:
    text = f.read()

text = text.replace('_', '\_', text.count('_'))
text = text.replace('$', '\$', text.count('$'))

with open('param.tex', 'w') as f:
    f.write(text)
