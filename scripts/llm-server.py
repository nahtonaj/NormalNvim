#!/usr/bin/env python3
"""
Simple HTTP server that wraps the llm CLI tool for use with avante.nvim
Usage: python llm-server.py [--port PORT]
"""

import json
import subprocess
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs
import argparse


class LLMHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)

        try:
            data = json.loads(post_data.decode('utf-8'))
            messages = data.get('messages', [])
            model = data.get('model', 'claude-3-7-sonnet')
            stream = data.get('stream', False)

            # Build prompt from messages
            prompt_parts = []
            for msg in messages:
                role = msg.get('role', '')
                content = msg.get('content', '')
                if role == 'system':
                    prompt_parts.append(f"System: {content}")
                elif role == 'user':
                    prompt_parts.append(content)
                elif role == 'assistant':
                    prompt_parts.append(f"Assistant: {content}")

            prompt = "\n\n".join(prompt_parts)

            # Execute llm command
            cmd = ['llm', '-m', model, prompt]
            result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

            if result.returncode != 0:
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                error_response = {
                    'error': {
                        'message': f'llm command failed: {result.stderr}',
                        'type': 'llm_error'
                    }
                }
                self.wfile.write(json.dumps(error_response).encode())
                return

            # Send response
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()

            if stream:
                # Simulate streaming response (avante expects this format)
                response = {
                    'id': 'local-llm',
                    'object': 'chat.completion.chunk',
                    'created': 0,
                    'model': model,
                    'choices': [{
                        'index': 0,
                        'delta': {'content': result.stdout},
                        'finish_reason': 'stop'
                    }]
                }
            else:
                response = {
                    'id': 'local-llm',
                    'object': 'chat.completion',
                    'created': 0,
                    'model': model,
                    'choices': [{
                        'index': 0,
                        'message': {
                            'role': 'assistant',
                            'content': result.stdout
                        },
                        'finish_reason': 'stop'
                    }]
                }

            self.wfile.write(json.dumps(response).encode())

        except Exception as e:
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            error_response = {
                'error': {
                    'message': str(e),
                    'type': 'server_error'
                }
            }
            self.wfile.write(json.dumps(error_response).encode())

    def log_message(self, format, *args):
        # Suppress default logging or customize as needed
        sys.stderr.write(f"{self.address_string()} - {format % args}\n")


def main():
    parser = argparse.ArgumentParser(description='LLM CLI HTTP Server')
    parser.add_argument('--port', type=int, default=8765, help='Port to listen on')
    args = parser.parse_args()

    server = HTTPServer(('127.0.0.1', args.port), LLMHandler)
    print(f"LLM server running on http://127.0.0.1:{args.port}")
    print("Press Ctrl+C to stop")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        server.shutdown()


if __name__ == '__main__':
    main()
