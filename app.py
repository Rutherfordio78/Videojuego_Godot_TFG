from flask import Flask, render_template, request, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import os
from models import db, Subscriber, User, PublicPost, Comment, DevReport

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///game_site.db'
db.init_app(app)

# Routes
@app.route('/')
def home():
    return render_template('home.html')

@app.route('/game-info')
def game_info():
    return render_template('game_info.html')

@app.route('/dev-insights')
def dev_insights():
    return render_template('dev_insights.html')

@app.route('/subscribe', methods=['GET', 'POST'])
def subscribe():
    if request.method == 'POST':
        email = request.form.get('email')
        
        # Check if email already exists
        existing_subscriber = Subscriber.query.filter_by(email=email).first()
        if existing_subscriber:
            flash('This email is already subscribed!')
            return redirect(url_for('subscribe'))
        
        # Add new subscriber
        new_subscriber = Subscriber(email=email)
        db.session.add(new_subscriber)
        db.session.commit()
        
        flash('Thanks for subscribing!')
        return redirect(url_for('home'))
    
    return render_template('subscribe.html')

# User authentication routes
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')
        
        # Validation
        if password != confirm_password:
            flash('Passwords do not match!')
            return redirect(url_for('register'))
        
        # Check if username or email already exists
        existing_user = User.query.filter_by(username=username).first()
        if existing_user:
            flash('Username already exists!')
            return redirect(url_for('register'))
        
        existing_email = User.query.filter_by(email=email).first()
        if existing_email:
            flash('Email already registered!')
            return redirect(url_for('register'))
        
        # Create new user
        new_user = User(
            username=username,
            email=email,
            password_hash=generate_password_hash(password)
        )
        db.session.add(new_user)
        db.session.commit()
        
        flash('Registration successful! Please log in.')
        return redirect(url_for('login'))
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        # Find user
        user = User.query.filter_by(username=username).first()
        
        # Check if user exists and password is correct
        if not user or not check_password_hash(user.password_hash, password):
            flash('Invalid username or password!')
            return redirect(url_for('login'))
        
        # Set session
        session['user_id'] = user.id
        session['username'] = user.username
        
        flash(f'Welcome back, {user.username}!')
        return redirect(url_for('social'))
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    # Clear session
    session.pop('user_id', None)
    session.pop('username', None)
    
    flash('You have been logged out.')
    return redirect(url_for('home'))

# Social page routes
@app.route('/social')
def social():
    # Get all public posts
    public_posts = PublicPost.query.order_by(PublicPost.date_posted.desc()).all()
    
    return render_template('social.html', public_posts=public_posts)

@app.route('/social/public/new', methods=['GET', 'POST'])
def new_public_post():
    # Check if user is logged in
    if 'user_id' not in session:
        flash('You need to be logged in to create a post!')
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        title = request.form.get('title')
        content = request.form.get('content')
        
        # Create new post
        new_post = PublicPost(
            title=title,
            content=content,
            user_id=session['user_id']
        )
        db.session.add(new_post)
        db.session.commit()
        
        flash('Your post has been created!')
        return redirect(url_for('social'))
    
    return render_template('new_public_post.html')

@app.route('/social/public/<int:post_id>')
def view_public_post(post_id):
    post = PublicPost.query.get_or_404(post_id)
    return render_template('view_public_post.html', post=post)

@app.route('/social/public/<int:post_id>/comment', methods=['POST'])
def add_comment(post_id):
    # Check if user is logged in
    if 'user_id' not in session:
        flash('You need to be logged in to comment!')
        return redirect(url_for('login'))
    
    post = PublicPost.query.get_or_404(post_id)
    content = request.form.get('content')
    
    # Create new comment
    new_comment = Comment(
        content=content,
        user_id=session['user_id'],
        post_id=post_id
    )
    db.session.add(new_comment)
    db.session.commit()
    
    flash('Your comment has been added!')
    return redirect(url_for('view_public_post', post_id=post_id))

@app.route('/social/dev')
def dev_reports():
    # Check if user is logged in
    if 'user_id' not in session:
        flash('You need to be logged in to view developer reports!')
        return redirect(url_for('login'))
    
    # Get all dev reports
    bug_reports = DevReport.query.filter_by(report_type='bug').order_by(DevReport.date_posted.desc()).all()
    suggestions = DevReport.query.filter_by(report_type='suggestion').order_by(DevReport.date_posted.desc()).all()
    
    return render_template('dev_reports.html', bug_reports=bug_reports, suggestions=suggestions)

@app.route('/social/dev/new', methods=['GET', 'POST'])
def new_dev_report():
    # Check if user is logged in
    if 'user_id' not in session:
        flash('You need to be logged in to create a report!')
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        title = request.form.get('title')
        content = request.form.get('content')
        report_type = request.form.get('report_type')
        
        # Create new report
        new_report = DevReport(
            title=title,
            content=content,
            report_type=report_type,
            user_id=session['user_id']
        )
        db.session.add(new_report)
        db.session.commit()
        
        flash('Your report has been submitted!')
        return redirect(url_for('dev_reports'))
    
    return render_template('new_dev_report.html')

# Context processor to pass current year to all templates
@app.context_processor
def inject_current_year():
    return {'current_year': datetime.now().year}

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)