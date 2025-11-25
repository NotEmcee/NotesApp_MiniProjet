import os
import psycopg2
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  


def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get('DB_HOST', 'notes-db'),
        database=os.environ.get('DB_NAME', 'notesdb'),
        user=os.environ.get('DB_USER', 'postgres'),
        password=os.environ.get('DB_PASSWORD', 'password')
    )
    return conn

@app.route('/notes', methods=['GET'])
def get_notes():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT * FROM notes ORDER BY id DESC;')
        notes = cur.fetchall()
        cur.close()
        conn.close()

        notes_list = [{'id': n[0], 'content': n[1]} for n in notes]
        return jsonify(notes_list)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/add', methods=['POST'])
def add_note():
    try:
        content = request.json['content']
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('INSERT INTO notes (content) VALUES (%s)', (content,))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'message': 'Note ajoutée !'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/delete', methods=['POST', 'DELETE'])
def delete_note():
    try:
        
        note_id = request.json.get('id')
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('DELETE FROM notes WHERE id = %s', (note_id,))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'message': 'Note supprimée !'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)