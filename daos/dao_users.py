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
