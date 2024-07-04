from flask import Blueprint, request, jsonify, session, render_template

auth = Blueprint('auth', __name__)


@auth.route('/login', methods=['POST'])
def get_all_articles():
    pass


@auth.route('/logout', methods=['POST'])
def create_article():
    pass
