from flask import Flask

# blueprints
from auth import auth
from api import api
from admin import admin
from blog import blog

# initialise app
app = Flask(__name__)

# register blueprints
app.register_blueprint(auth.auth, url_prefix='/auth')
app.register_blueprint(api.api, url_prefix='/api')
app.register_blueprint(admin.admin, url_prefix='/a')
app.register_blueprint(blog.blog)


# warmp reguests
# @app.route('/_ah/warmup')
# def warmup():
#     pass


if __name__ == '__main__':
    app.run(host='127.0.0.2', port=9000, debug=True)
