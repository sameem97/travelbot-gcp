import os
from flask import Flask, render_template

# Initialize the Flask application
app = Flask(__name__)

# Define the main route
@app.route('/')
def home():
    """
    Renders the main page with the Dialogflow Messenger chat bubble.
    """
    return render_template('index.html')

# Run the Flask app
if __name__ == '__main__':
    # It's recommended to run Flask apps using a WSGI server in production,
    # but for development, the built-in server is fine.
    # Get the PORT from environment variable or default to 8080
    port = int(os.environ.get('PORT', 8080))
    app.run(debug=False, host='0.0.0.0', port=port)
