import mysql.connector

# Attempt to establish a connection to check if the module is working
try:
    # Replace with your actual MySQL server details
    connection = mysql.connector.connect(
        host='localhost',
        user='your_username',
        password='your_password',
        database='your_database'
    )

    if connection.is_connected():
        print("MySQL Connector Python module is successfully running.")
        connection.close()

except mysql.connector.Error as err:
    print(f"Error: {err}")
