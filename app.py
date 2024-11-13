from flask import Flask, request, jsonify, render_template, redirect, url_for, session, flash, g
from flask_cors import CORS
from flask_bcrypt import Bcrypt
import os
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import InputRequired, Length, EqualTo, ValidationError, Email
#import json
from functools import wraps
from datetime import timedelta
import math
#import logging

from daos.sql_connection import get_sql_connection
from daos.dao_practice_sets import get_one_user_practice_sets, get_one_user_practice_sets_pagination, get_specific_practice_set, insert_practice_set, update_practice_set, delete_practice_set, add_set_to_favorites, remove_set_from_favorites, get_public_practice_sets_pagination
from daos.dao_practice_sessions import insert_practice_session, get_all_user_practice_sessions, get_specific_practice_session
from daos.dao_users import username_exists, get_user_profile_info, get_user_password_hash, update_user_password
# App configuration

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": ["http://localhost:5000", "http://127.0.0.1:5000"], "supports_credentials": True}}) # Fix CORS errors
app.config['SESSION_COOKIE_SECURE'] = False  # For development without HTTPS
app.config['SESSION_COOKIE_HTTPONLY'] = True # Prevent cross-site scripting / Cookie cannot be manipulated by client-side JS
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax' # Lax - Protect against CSRF attacks without breaking too many cross-site interactions. Good for balance between security and usability.
app.config['UPLOAD_FOLDER'] = os.path.join(app.root_path, 'static', 'uploads')
app.config['AVATAR_UPLOAD_FOLDER'] = os.path.join(app.config['UPLOAD_FOLDER'], 'avatars')
app.secret_key = os.getenv('SECRET_KEY') # required for session management
app.permanent_session_lifetime = timedelta(days = 1) # how long a permanent session should last; need to set a session as permanent to be applicable because it is not by default

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
    
class ChangePasswordForm(FlaskForm):
    old_password = PasswordField('Old password', validators=[InputRequired()])
    new_password = PasswordField('New password', validators=[InputRequired(), Length(min=6, max=100)])
    confirm_new_password = PasswordField('Confirm new password', validators=[InputRequired(), EqualTo('new_password', message='Passwords must match'), Length(min=6, max=100)])
    submit = SubmitField('Change password')
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

@app.template_filter('floor')
def floor_filter(value):
    """Returns the floor of the value."""
    return math.floor(value)

#======= END FUNCTIONS =======

#======= ROUTES / API END-POINTS ======= 

@app.route('/')
def home():
    print('current session: ', session)
    print('home route accessed')
    if 'user_id' in session:
        return render_template('index.html', username = session['username'])
    else:
        return render_template('index.html')

# Authentication
@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()

    if 'user_id' in session:
        flash('Already logged in.')
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
            session.permanent = True # session expries after 1 day; configuration in variable app.permanent_session_lifetime 
            flash('Login successful!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Login failed. Check your username and password.', 'danger')
        
    return render_template('login.html', form = form)

@app.route('/register', methods=['GET', 'POST'])
def register():
    print('Current session: ', session)
    print('Register route accessed')
    if 'user_id' in session:
        flash('You first need to log out to register a new account.')
        return redirect(url_for('home'))

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
    if 'user_id' in session: # to prevent the flash from showing if someone accesses logout route while not being logged in
        session.clear()
        flash('You have been logged out.', 'success')
    return redirect(url_for('home'))

@app.route('/public_sets', methods = ['GET'])
def public_sets():
    print('public sets accessed')

    return render_template('public_sets.html', username = session['username'] if 'username' in session else None) # need to pass session so that nav bar works correctly

@app.route('/my_sets')
@login_required
def my_sets():
    print('Current session: ', session)
    print('my_sets route accessed')

    return render_template('my_sets.html', username = session['username']) # need to pass session so that nav bar works correctly

@app.route('/new_set')
@login_required
def new_set():
    print('Current session: ', session)
    print('new_set route accessed')

    return render_template('new_set.html', username = session['username']) # need to pass session username so that nav bar works correctly

@app.route('/practice/<int:id>')
def practice(id):
    print('Current session: ', session)
    print('practice route accessed')

    if 'user_id' in session:
        user_id = session['user_id'] 
    else:
        user_id = 0 # if the user is not logged in, pass 0 to the SQL query to only access public sets
    
    response = get_specific_practice_set(get_db(), user_id, {'practice_set_id' : id})
    print(response)

    r_status_code = response[1]
    if r_status_code == 404: # set not found or no permission for the user
        return "You don't have permission to view this or this doesn't exist.", 404

    return render_template('practice.html', username = session['username'] if 'username' in session else None, id = id, response = response[0]) # need to pass session username so that nav bar works correctly

@app.route('/edit_set/<int:id>')
@login_required
def edit_set(id):
    print('Current session: ', session)
    print(f'edit_set/{id} route accessed')

    response = get_specific_practice_set(get_db(), session['user_id'], {'practice_set_id' : id})
    print(response)

    r_status_code = response[1]
    if r_status_code == 404: # set not found or no permission for the user
        return "You don't have permission to view this or this doesn't exist.", 404

    #response = jsonify(response[0])
    print(response[0])

    return render_template('edit_set.html', username = session['username'], id = id, response = response[0])


@app.route('/practice_history')
@login_required
def practice_history():
    print('Current session: ', session)
    print('/practice_history route accessed')

    page = request.args.get('page', default=1, type=int)

    all_practice_sessions = get_all_user_practice_sessions(get_db(), session['user_id'], page)
    print(all_practice_sessions)
    return render_template('practice_history.html', username = session['username'], all_practice_sessions = all_practice_sessions, page = page)

@app.route('/practice_history/<int:id>')
@login_required
def practice_history_id(id):
    print('Current session: ', session)
    print(f'/practice_history/{id} route accessed')

    practice_session = get_specific_practice_session(get_db(), session['user_id'], id)
    if practice_session[1] == 404: # If no such practice session is found
        return practice_session[0], 404 # practice_session[0] is an error message
    elif practice_session[1] == 501:
         return practice_session[0], 501 # practice_session[0] is an error message
    print('practice_session', practice_session)
    print('practice_session[0]', practice_session[0])
    return render_template('practice_history_id.html', id = id, username = session['username'], practice_session = practice_session)

@app.route('/user/<string:username>')
def user_profile(username):
    print('Current session: ', session)
    print(f'/user/{username} route accessed')
    
    if not username_exists(get_db(), username): # If user with such name does not exist
        return f'User {username} was not found.', 404

    profile_data = get_user_profile_info(get_db(), username)
    print(profile_data)

    return render_template('user.html', username = session['username'] if 'username' in session else None, profile_data = profile_data if profile_data else None) # if / else to pass None if the user is not logged in to prevent an error

@app.route('/edit_profile')
@login_required
def edit_profile():
    print('Current session: ', session)
    print(f'/edit_profile route accessed')

    profile_data = get_user_profile_info(get_db(), session['username'])
    print(profile_data)

    return render_template('edit_profile.html', username = session['username'], profile_data = profile_data)

@app.route('/change_password', methods = ['GET','POST'])
@login_required
def change_password():
    print('Current session: ', session)
    print(f'/change_password route accessed')
    
    profile_data = get_user_profile_info(get_db(), session['username'])
    form = ChangePasswordForm()

    if form.is_submitted():
        form.validate()
        print(form.validate())
        form_old_password = form.old_password.data
        form_new_password = form.new_password.data
        form_confirm_new_password = form.confirm_new_password.data
        db_old_password_hash = str(get_user_password_hash(get_db(), session['user_id'])[0])

        if bcrypt.check_password_hash(db_old_password_hash, form_old_password): # ({hash}, {plaintext}) passwords match
            if form_new_password == form_confirm_new_password:
                password_hash = bcrypt.generate_password_hash(form_new_password).decode('utf-8')
                if update_user_password(get_db(), session['user_id'], password_hash) == True:
                    flash('Password changed', 'success')
                    return redirect(url_for('edit_profile'), code = 302)
                else:
                    flash('Error')
        else: # passwords do not match
            print('Passwords do not match')

    return render_template('change_password.html', username = session['username'], profile_data = profile_data, form = form)


# ===========================================================
#                           APIs
# ===========================================================

# Get a list of practice sets for the logged in user
@app.route('/get_practice_sets', methods = ['GET'])
@login_required
def get_practice_sets():
    print('current session: ', session)
    print('get_practice_sets route accessed')
    
    response = get_one_user_practice_sets(get_db(), session['user_id'])

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

@app.route('/get_practice_sets/<int:id>')
@login_required
def get_practice_sets_page(id):
    print('Current session: ', session)
    print(f'/get_practice_sets/{id} route accessed')

    response = get_one_user_practice_sets_pagination(get_db(), session['user_id'], id)
    print(response)
    if isinstance(response, tuple):
        return jsonify(message=response[0], row_count = response[1]), response[2]

    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500

@app.route('/get_public_practice_sets/<int:page_id>', methods = ['GET'])
def get_public_practice_sets(page_id):
    #print('Current session: ', session)
    print(f'/get_public_practice_sets/{page_id} route accessed')

    response = get_public_practice_sets_pagination(get_db(), page_id)

    return jsonify(message = response[0], row_count = response[1]), response[2]



# Get a specific practice set
@app.route('/get_full_practice_set', methods = ['GET', 'POST'])
#@login_required
def get_full_practice_set():
    #print('current session: ', session)
    print('get_full_practice_set route accessed')
    
    request_payload = request.get_json()
    user_id = session['user_id'] if 'user_id' in session else None
    response = get_specific_practice_set(get_db(), user_id, request_payload)

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

# Insert set
@app.route('/insert_set', methods = ['POST'])
@login_required
def insert_set():
    print('current session: ', session)
    print('insert_set route accessed')
    
    request_payload = request.get_json()
    response = insert_practice_set(get_db(), session['user_id'], request_payload)

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

@app.route('/update_set', methods = ['PATCH'])
@login_required
def update_set():
    print('current session: ', session)
    print('insert_set route accessed')
    
    request_payload = request.get_json()
    response = update_practice_set(get_db(), session['user_id'], request_payload)

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

@app.route('/delete_set', methods = ['DELETE'])
@login_required
def delete_set():
    print('current session: ', session)
    print('delete_set route accessed')
    request_payload = request.get_json()
    response = delete_practice_set(get_db(), session['user_id'], request_payload)

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

@app.route('/add_favorite_set', methods = ["POST"])
@login_required
def add_favorite_set():
    print('current session: ', session)
    print('add_set_to_favorites route accessed')
    request_payload = request.get_json()
    response = add_set_to_favorites(get_db(), session['user_id'], request_payload)

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

@app.route('/remove_favorite_set', methods = ['DELETE'])
@login_required
def remove_favorite_set():
    print('current session: ', session)
    print('remove_favorite_set route accessed')
    request_payload = request.get_json()
    response = remove_set_from_favorites(get_db(), session['user_id'], request_payload)

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

@app.route('/add_practice_session', methods = ['POST'])
@login_required
def add_practice_session():
    print('current session: ', session)
    print('add_practice_session route accessed')
    request_payload = request.get_json()
    response = insert_practice_session(get_db(), session['user_id'], request_payload)

    # Assuming 'response' is a tuple (message, status_code)
    if isinstance(response, tuple) and len(response) == 2:
        return jsonify(message=response[0]), response[1]
    # Handle unexpected response formats
    return jsonify(message="Unexpected response format."), 500  # Return 500 if response is invalid

@app.route('/get_user_sessions', methods = ['GET'])
@login_required
def get_user_practice_sessions():
    print('current session: ', session)
    print('get_user_sessions route accessed')
    
    response = get_all_user_practice_sessions(get_db(), session['user_id'])
    return response

#======= END ROUTES / API END-POINTS ======= 

if __name__ == '__main__':
    environment = os.getenv('ENVIRONMENT', 'development') # default to 'development' if not found
    if environment == 'production':
        print('Starting Flask Production Server')
        # WSGI server will start the app
    else:
        print('Starting Flask Development Server')
        app.run(port = 5000, debug = True)