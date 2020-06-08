from flask import Blueprint, request, jsonify, session, render_template

blog = Blueprint('blog', __name__)


@blog.route('/<string:article_name>', methods=['GET'])
def article(article_name: str):
    pass


@blog.route('/', methods=['GET'])
def articles():
    return "apple"
