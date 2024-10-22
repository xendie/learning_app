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



def insert_practice_session(connection, user_id, request_payload):
    cursor = connection.cursor()

    if 'set_id' not in request_payload or 'answers_list' not in request_payload:
        return 'Not enough parameters provided. Required: set_id, answers_list[]', 400

    set_id = request_payload['set_id']
    answers_list = request_payload['answers_list']
    
    if check_if_set_is_public(request_payload, cursor) == False:
        if check_if_user_owns_this_set(request_payload, user_id, cursor) == False:
            return "The user does not have permission to view this set or it does not exist.", 401
    
    try:
        params_query_insert_session = [user_id, set_id]
        query_insert_session = """
            INSERT INTO practice_session(user_id, practice_set_id)
            VALUES (%s, %s)  
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


"""
{
    "set_id" : 40,
    "answers_list": [
        {
            "item_id": 1,
            "user_answer" : 1,
            "time_started" : "2024-10-22 16:10:00.000",
            "time_ended" : "2024-10-22 16:11:00.000"
        }
        {
            "item_id": 2,
            "user_answer" : 1,
            "time_started" : "2024-10-22 16:11:00.000",
            "time_ended" : "2024-10-22 16:12:00.000"
        },
        {
            "item_id": 3,
            "user_answer" : 1,
            "time_started" : "2024-10-22 16:12:00.000",
            "time_ended" : "2024-10-22 16:13:00.000"
        },
        {
            "item_id": 4,
            "user_answer" : 1,
            "time_started" : "2024-10-22 16:13:00.000",
            "time_ended" : "2024-10-22 16:14:00.000"
        }
    ]
}
"""