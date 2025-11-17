from flask import Flask, jsonify
import datetime
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return f"""
    <h1>🚀 Simple Python App</h1>
    <p>Hostname: {socket.gethostname()}</p>
    <p>Time: {datetime.datetime.now()}</p>
    <p>Status: <span style="color: green;">✅ RUNNING</span></p>
    <hr>
    <a href="/health">Health Check</a> | 
    <a href="/api/status">API Status</a>
    """

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": str(datetime.datetime.now()),
        "hostname": socket.gethostname()
    })

@app.route('/api/status')
def api_status():
    return jsonify({
        "application": "Simple Python App",
        "version": "1.0.0",
        "environment": "production",
        "deployed_at": str(datetime.datetime.now())
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
