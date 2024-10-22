from flask import Flask, request, jsonify, render_template, redirect, url_for, session, flash, g
from flask_cors import CORS
from flask_bcrypt import Bcrypt
import os
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import InputRequired, Length, EqualTo, ValidationError, Email
#import json
from functools import wraps
#import logging

from daos.sql_connection import get_sql_connection
from daos.dao_practice_sets import get_one_user_practice_sets, get_specific_practice_set, insert_practice_set, update_practice_set, delete_practice_set, add_set_to_favorites, remove_set_from_favorites

# App configuration

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": ["http://localhost:5000", "http://127.0.0.1:5000"], "supports_credentials": True}})
app.config['SESSION_COOKIE_SECURE'] = False  # For development without HTTPS
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.secret_key = os.getenv('SECRET_KEY')
bcrypt = Bcrypt(app) # For creating password hashes

# Open a database connection at the start of a request and store it in g
def get_db():
    if 'db' not in g:
        g.db = get_sql_connection()  # Create a new connection if one doesn't exist
    return g.db

# Close the connection after each request
@app.teardown_appcontext
def close_db(exception=None):
    db = g.pop('db', None)
    if db is not None:
        db.close()

# ======= FORMS ======= 

class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired(), Length(min=4, max=50)])
    password = PasswordField('Password', validators=[InputRequired(), Length(min=6, max=100)])
    confirm_password = PasswordField('Confirm Password', validators=[InputRequired(), EqualTo('password', message='Passwords must match')])
    email = StringField('E-mail', validators=[InputRequired(), Email(message='Invalid email address'), Length(min=4, max=100)])
    submit = SubmitField('Register')

    # Custom validator to ensure the username is unique
    def validate_username(self, username):
        connection = get_db()
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE username = %s", (username.data,))
        user = cursor.fetchone()
        cursor.close()
        #connection.close()
        if user:
            raise ValidationError("Username already exists. Please choose another one.")

# User Login Form
class LoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired(), Length(min=4, max=50)])
    password = PasswordField('Password', validators=[InputRequired()])
    submit = SubmitField('Login')


# ======= END FORMS ======= 

#======= FUNCTIONS ======= 

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        print('current session: ', session)
        if 'user_id' not in session:
            flash('Please log in to access this page.', 'warning')
            print('redirecting the user to login page')
            return redirect(url_for('login'), code = 302)

        return f(*args, **kwargs)
    return decorated_function

#======= END FUNCTIONS =======

#======= ROUTES / API END-POINTS ======= 

@app.route('/')
def home():
    print('current session: ', session)
    print('home route accessed')
    return '<h1>Hello there</h1>'

# Authentication
@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()

    if 'user_id' in session:
        return redirect(url_for('home'))

    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data

        connection = get_db()
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
        user = cursor.fetchone()
        cursor.close()

        if user and bcrypt.check_password_hash(user['password'], password):
            session['user_id'] = user['id']
            session['username'] = user['username']
            flash('Login successful!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Login failed. Check your username and password.', 'danger')
        
    return render_template('login.html', form = form)

@app.route('/register', methods=['GET', 'POST'])
def register():
    print('Current session: ', session)
    print('Register route accessed')

    form = RegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        password_hash = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        email = form.email.data

        connection = get_db()
        cursor = connection.cursor()
        cursor.execute("INSERT INTO users (username, password, `e-mail`) VALUES (%s, %s, %s)", (username, password_hash, email))
        connection.commit()
        cursor.close()
        #connection.close()

        flash('Registration successful! Please log in.', 'success')
        return redirect(url_for('login'))

    return render_template('register.html', form=form)

@app.route('/logout')
def logout():
    print('Current session: ', session)
    print('Logout route accessed')
    session.clear()
    flash('You have been logged out.', 'success')
    return redirect(url_for('login'))


# Get a list of practice sets for the logged in user
@app.route('/get_practice_sets', methods = ['GET'])
@login_required
def get_practice_sets():
    print('current session: ', session)
    print('get_practice_sets route accessed')
    
    response = get_one_user_practice_sets(get_db(), session['user_id'])

    return jsonify(response)

# Get a specific practice set
@app.route('/get_full_practice_set', methods = ['GET'])
@login_required
def get_full_practice_set():
    print('current session: ', session)
    print('get_specific_practice_set route accessed')
    
    request_payload = request.get_json()

    response = get_specific_practice_set(get_db(), session['user_id'], request_payload)

    return jsonify(response)

# Insert set
@app.route('/insert_set', methods = ['POST'])
@login_required
def insert_set():
    print('current session: ', session)
    print('insert_set route accessed')
    
    request_payload = request.get_json()
    response = insert_practice_set(get_db(), session['user_id'], request_payload)

    return jsonify(response)

@app.route('/update_set', methods = ['PATCH'])
@login_required
def update_set():
    print('current session: ', session)
    print('insert_set route accessed')
    
    request_payload = request.get_json()
    response = update_practice_set(get_db(), session['user_id'], request_payload)

    return jsonify(response)

@app.route('/delete_set', methods = ['DELETE'])
@login_required
def delete_set():
    print('current session: ', session)
    print('delete_set route accessed')
    request_payload = request.get_json()
    response = delete_practice_set(get_db(), session['user_id'], request_payload)

    return jsonify(response)

@app.route('/add_favorite_set', methods = ["POST"])
@login_required
def add_favorite_set():
    print('current session: ', session)
    print('add_set_to_favorites route accessed')
    request_payload = request.get_json()
    response = add_set_to_favorites(get_db(), session['user_id'], request_payload)

    return jsonify(response)

@app.route('/remove_favorite_set', methods = ['DELETE'])
@login_required
def remove_favorite_set():
    print('current session: ', session)
    print('add_set_to_favorites route accessed')
    request_payload = request.get_json()
    response = remove_set_from_favorites(get_db(), session['user_id'], request_payload)

    return jsonify(response)

#======= END ROUTES / API END-POINTS ======= 

if __name__ == '__main__':
    print('Starting Flask Server')
    app.run(port = 5000, debug = True)
