from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

# Model for email subscribers
class Subscriber(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    date_subscribed = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<Subscriber {self.email}>'

# Model for users
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    date_registered = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    public_posts = db.relationship('PublicPost', backref='author', lazy=True)
    dev_reports = db.relationship('DevReport', backref='author', lazy=True)
    
    def __repr__(self):
        return f'<User {self.username}>'

# Model for public posts
class PublicPost(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    content = db.Column(db.Text, nullable=False)
    date_posted = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    
    # Relationships
    comments = db.relationship('Comment', backref='post', lazy=True)
    
    def __repr__(self):
        return f'<PublicPost {self.title}>'

# Model for comments on public posts
class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    date_posted = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey('public_post.id'), nullable=False)
    
    # Relación con el usuario
    user = db.relationship('User', backref='comments', lazy=True)
    
    def __repr__(self):
        return f'<Comment {self.id}>'

# Model for developer reports (bugs, suggestions)
class DevReport(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    content = db.Column(db.Text, nullable=False)
    report_type = db.Column(db.String(20), nullable=False)  # 'bug' or 'suggestion'
    status = db.Column(db.String(20), default='pending')  # 'pending', 'in-progress', 'resolved'
    date_posted = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    
    def __repr__(self):
        return f'<DevReport {self.title}>'