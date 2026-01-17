from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello! The DevOps Python app is running successfully."

if __name__ == '__main__':
    # Run on 0.0.0.0 to make it accessible outside the container
    app.run(host='0.0.0.0', port=5000)