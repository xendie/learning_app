def username_exists(connection, username):
    cursor = connection.cursor()
    query = "SELECT username FROM users WHERE username = %s"
    params = (username,)
    try:
        cursor.execute(query, params)
        result = cursor.fetchone()
        if result == None:
            return False
        return True
    except Exception as e:
        print(f"Error: {e}")
        return str(e), 500    
    finally:
        cursor.close()

def get_user_profile_info(connection, username):
    cursor = connection.cursor(dictionary = True)
    query = "SELECT username, avatar_url, description, created_timestamp FROM users WHERE username = %s"
    params = (username,)
    try:
        cursor.execute(query, params)
        result = cursor.fetchone()
        if result == None:
            raise Exception
        return result
    except Exception as e:
        print(f"Error: {e}")
        return str(e), 500    
    finally:
        cursor.close()

def get_user_password_hash(connection, user_id):
    cursor = connection.cursor()
    query = "SELECT password FROM users WHERE id = %s"
    params = (user_id,)
    try:
        cursor.execute(query, params)
        result = cursor.fetchone()
        if result == None:
            print('No result from query')
            raise Exception
        return result
    except Exception as e:
        print(f"Error: {e}")
        return str(e), 500    
    finally:
        cursor.close()


def update_user_password(connection, user_id, new_password_hash):
    cursor = connection.cursor()
    query = """UPDATE users 
                SET password = %s
                WHERE id = %s"""
    params = (new_password_hash, user_id)

    try:
        cursor.execute(query, params)
        connection.commit()
        return True
    except Exception as e:
        print(f"Error: {e}")
        return str(e), 500    
    finally:
        cursor.close()



# =============
def get_user_by_provider(connection, provider, provider_id):
    """Get a user by OAuth provider (e.g., Google)"""
    cursor = connection.cursor(dictionary=True)
    query = "SELECT * FROM users WHERE provider=%s AND provider_id=%s"
    params = (provider, provider_id)
    try:
        cursor.execute(query, params)
        return cursor.fetchone()
    except Exception as e:
        print(f"Error: {e}")
        return None
    finally:
        cursor.close()


def create_oauth_user(connection, email, provider, provider_id, username=None):
    """Create a new user using OAuth info"""
    cursor = connection.cursor()
    query = """INSERT INTO users (`username`, `e-mail`, `provider`, `provider_id`)
               VALUES (%s, %s, %s, %s)"""
    params = (email, email, provider, provider_id) # username same as e-mail
    try:
        cursor.execute(query, params)
        connection.commit()
        return cursor.lastrowid
    except Exception as e:
        print(f"Error: {e}")
        return None
    finally:
        cursor.close()


def link_provider_to_existing_user(connection, user_id, provider, provider_id):
    """Link OAuth provider to an existing local user"""
    cursor = connection.cursor()
    query = """UPDATE users
               SET provider=%s, provider_id=%s
               WHERE id=%s"""
    params = (provider, provider_id, user_id)
    try:
        cursor.execute(query, params)
        connection.commit()
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False
    finally:
        cursor.close()


def get_user_by_email(connection, email):
    """Get a user by email (useful for linking accounts)"""
    cursor = connection.cursor(dictionary=True)
    query = "SELECT * FROM users WHERE email=%s"
    params = (email,)
    try:
        cursor.execute(query, params)
        return cursor.fetchone()
    except Exception as e:
        print(f"Error: {e}")
        return None
    finally:
        cursor.close()

def get_user_by_id(connection, id):
    """Get a user by email (useful for linking accounts)"""
    cursor = connection.cursor(dictionary=True)
    query = "SELECT * FROM users WHERE id=%s"
    params = (id,)
    try:
        cursor.execute(query, params)
        return cursor.fetchone()
    except Exception as e:
        print(f"Error: {e}")
        return None
    finally:
        cursor.close()