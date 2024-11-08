def check_if_user_owns_this_set(request_payload, user_id, cursor):
    if 'set_id' not in request_payload:
        raise Exception("Failed. No set_id provided")

    # security check - if user is the author of the set, only set authors can edit them
    try:
        set_id_check = int(request_payload['set_id'])  # Validate set_id
    except (ValueError, TypeError) as e:
        raise ValueError(f"Invalid set_id provided: {e}")

    params = [user_id]
    query = "SELECT id FROM practice_set WHERE user_id = %s"
    cursor.execute(query, params)
    user_set_ids = [int(id[0]) for id in cursor]

    if set_id_check not in user_set_ids:
        return False
        raise PermissionError("User is unauthorized to update this set.")
    return True


def check_if_set_is_public(request_payload, cursor):
    # public sets can be accessed by anyone
    if 'set_id' not in request_payload:
        raise Exception("Failed. No set_id provided")
    try:
        set_id_check = int(request_payload['set_id'])  # Validate set_id
    except (ValueError, TypeError) as e:
        raise ValueError(f"Invalid set_id provided: {e}")

    params = [request_payload['set_id']]
    query = "SELECT id, private FROM practice_set WHERE id = %s"
    cursor.execute(query, params)

    result = cursor.fetchone()

    if result is None:
        return False
        #raise Exception("No set found with the provided ID.")
        
    is_private = int(result[1])

    if is_private == 1:
        return False
        #raise PermissionError("User is unauthorized to update this set.")
    return True


# Create a trigger in DB - check if set is_deleted before creating a practice session
def insert_practice_session(connection, user_id, request_payload):
    cursor = connection.cursor()

    if 'set_id' not in request_payload or 'answers_list' not in request_payload:
        return 'Not enough parameters provided. Required: set_id, answers_list[]', 400

    set_id = request_payload['set_id']
    answers_list = request_payload['answers_list']
    time_started = request_payload['time_started']
    time_ended = request_payload['time_ended']
    
    if check_if_set_is_public(request_payload, cursor) == False:
        if check_if_user_owns_this_set(request_payload, user_id, cursor) == False:
            return "The user does not have permission to view this set or it does not exist.", 401
    
    try:
        params_query_insert_session = [user_id, set_id, time_started, time_ended]
        query_insert_session = """
            INSERT INTO practice_session(user_id, practice_set_id, time_started, time_ended)
            VALUES (%s, %s, %s, %s)  
            """
        cursor.execute(query_insert_session, params_query_insert_session)
        last_session_id = cursor.lastrowid

        for item in answers_list:
            params_query_insert_session_item = [last_session_id, item['item_id'], item['user_answer'], item['time_started'], item['time_ended']]
            query_insert_session_item = """
                INSERT INTO practice_session_item(practice_session_id, item_id, user_answer, time_started, time_ended)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(query_insert_session_item, params_query_insert_session_item)

        connection.commit()
        return "Practice session saved.", 201
    except Exception as e:
        connection.rollback()
        return f"Error {str(e)}", 501
    finally:
        cursor.close()



def get_all_user_practice_sessions(connection, user_id, page):
    # To-do: make sure only relevant sets are shown
    # What if there are thousands of results? - In the future show only a portion of the results, maybe just the count and add pagination
    cursor = connection.cursor()
    row_count_query = "SELECT COUNT(*) FROM v_practice_session_total_score WHERE user_id = %s"
    row_count_query_params = (user_id,)

    query = "SELECT * FROM v_practice_session_total_score WHERE user_id = %s ORDER BY id DESC LIMIT 20 OFFSET %s"
    offset = (page - 1)* 20 # so that we start with offset 0 instead of 20
    query_params = (user_id, offset)
    try:
        cursor.execute(row_count_query, row_count_query_params)
        row_count = cursor.fetchone()[0]
        print(row_count)

        cursor.execute(query, query_params)
        response = []

        for (id, user, set_owner, private, set_name, answers_correct, answers_total, time_ended, answers_correct_percent, duration) in cursor:
            response.append({
                'id' : id, 
                'user_id' : user, 
                'set_owner' : set_owner, 
                'private' : private, 
                'set_name' : set_name, 
                'answers_correct' : answers_correct, 
                'answers_total' : answers_total,
                'time_ended' : time_ended,
                'answers_correct_percent' : answers_correct_percent, 
                'duration' : duration
            })
        return response, {'row_count' : row_count}, 200

    except Exception as e:
        return f"Error {str(e)}", 501
    finally:
        cursor.close()

def get_specific_practice_session(connection, user_id, practice_session):
    cursor = connection.cursor()
    query_params = (practice_session, user_id)
    query = "SELECT * FROM v_practice_session_items WHERE practice_session_id = %s AND user_id = %s"
    
    try:
        cursor.execute(query, query_params)
        if cursor.fetchone() is None:
            return 'Not found or the session belongs to a different user', 404

        response = []

        for (practice_session_id, user, question, answer, user_answer, time_started, time_ended, set_name, duration) in cursor:
            response.append({
                'practice_session_id' : practice_session_id,
                'user' : user,
                'question' : question,
                'answer' : answer,
                'user_answer' : 'Right' if user_answer == 1 else 'Wrong',
                'time_started' : time_started,
                'time_ended' : time_ended,
                'set_name' : set_name,
                'duration' : duration
            })
        return response, 200

    except Exception as e:
        return f"Error {str(e)}", 501
    finally:
        cursor.close()