from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'This should not be reached - static files should handle all requests'

if __name__ == '__main__':
    app.run(debug=True) 