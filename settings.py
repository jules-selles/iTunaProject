import os
from os import environ

import dj_database_url
from boto.mturk import qualification

import otree.settings

import numpy

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Debug mode setting
# the environment variable OTREE_PRODUCTION controls whether Django runs in
# DEBUG mode. If OTREE_PRODUCTION==1, then DEBUG=False

#if environ.get('OTREE_PRODUCTION') not in {None, '', '0'}:
#    DEBUG = False
#else:
#    DEBUG = True

DEBUG = True

# Sentry service in production mode
#SENTRY_DSN = 'http://e0b873e62bfe4ec38b69265e4b7f76fc:1986db995f6444c6b1bb50fc06ce1eed@sentry.otree.org/117'

ADMIN_USERNAME = 'jselles'
# for security, best to set admin password in an environment variable

#ADMIN_PASSWORD = environ.get('OTREE_ADMIN_PASSWORD')
ADMIN_PASSWORD = 'ituna'

# don't share this with anybody.
SECRET_KEY = ')to-n3&(gtnv)ww2p8pei(*amxok8f%%i#+qzxojhk&f@hcaq-'

PAGE_FOOTER = ''

#room creation

ROOM_DEFAULTS = {}

#ROOMS = [
#    {
#        'name': 'iTuna_test1',
#        'display_name': 'iTuna_test1',
#        'participant_label_file': 'participant_test1.txt'
#    },
#    {
#        'name': 'iTuna_test2',
#        'display_name': 'iTuna_test2',
#        'participant_label_file': 'participant_test2.txt'
#    }
#]


# To use a database other than sqlite,
# set the DATABASE_URL environment variable.
# Examples:
# postgres://USER:PASSWORD@HOST:PORT/NAME
# mysql://USER:PASSWORD@HOST:PORT/NAME

DATABASES = {
        'default': dj_database_url.config(
        default='sqlite:///' + os.path.join(BASE_DIR, 'db.sqlite3')
    )
}

# AUTH_LEVEL:
# If you are launching a study and want visitors to only be able to
# play your app if you provided them with a start link, set the
# environment variable OTREE_AUTH_LEVEL to STUDY.
# If you would like to put your site online in public demo mode where
# anybody can play a demo version of your game, set OTREE_AUTH_LEVEL
# to DEMO. This will allow people to play in demo mode, but not access
# the full admin interface.

AUTH_LEVEL = environ.get('STUDY')

# setting for integration with AWS Mturk
AWS_ACCESS_KEY_ID = environ.get('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = environ.get('AWS_SECRET_ACCESS_KEY')


# e.g. EUR, CAD, GBP, CHF, CNY, JPY
REAL_WORLD_CURRENCY_CODE = 'euros'
USE_POINTS = False


# e.g. en, de, fr, it, ja, zh-hans
# see: https://docs.djangoproject.com/en/1.9/topics/i18n/#term-language-code
LANGUAGE_CODE = 'en'

# if an app is included in SESSION_CONFIGS, you don't need to list it here
INSTALLED_APPS = []

# SENTRY_DSN = ''

DEMO_PAGE_INTRO_TEXT = """
oTree Experiment setting for iTuna
"""

# from here on are qualifications requirements for workers
# see description for requirements on Amazon Mechanical Turk website:
# http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_QualificationRequirementDataStructureArticle.html
# and also in docs for boto:
# https://boto.readthedocs.org/en/latest/ref/mturk.html?highlight=mturk#module-boto.mturk.qualification

mturk_hit_settings = {
    'keywords': ['easy', 'bonus', 'choice', 'study'],
    'title': 'Title for your experiment',
    'description': 'Description for your experiment',
    'frame_height': 500,
    'preview_template': 'global/MTurkPreview.html',
    'minutes_allotted_per_assignment': 60,
    'expiration_hours': 7*24,  # 7 days
    # 'grant_qualification_id': 'YOUR_QUALIFICATION_ID_HERE',# to prevent retakes
    'qualification_requirements': [
        qualification.LocaleRequirement("EqualTo", "US"),
        qualification.PercentAssignmentsApprovedRequirement("GreaterThanOrEqualTo", 50),
        qualification.NumberHitsApprovedRequirement("GreaterThanOrEqualTo", 5),
        # qualification.Requirement('YOUR_QUALIFICATION_ID_HERE', 'DoesNotExist')
    ]
}

# if you set a property in SESSION_CONFIG_DEFAULTS, it will be inherited by all configs
# in SESSION_CONFIGS, except those that explicitly override it.
# the session config can be accessed from methods in your apps as self.session.config,
# e.g. self.session.config['participation_fee']

SESSION_CONFIG_DEFAULTS = {
    'real_world_currency_per_point': 0.05,
    'participation_fee': 0,
    'num_bots': 0,
    'doc': "",
    'mturk_hit_settings': mturk_hit_settings,
}

SESSION_CONFIGS = [
    {
        'name': 'XP1_p2',
        'display_name': "iTuna phase 2 TEST",
        'num_demo_participants': 3,
        'treatment': 'T1',
        'app_sequence': ['XP1p2FR']  # , 'survey', 'payment_info'],
    },
    {
        'name': 'XP1_p1',
        'display_name': "iTuna  phase 1 TEST",
        'num_demo_participants': 3,
        'treatment': 'T1',
        'app_sequence': ['XP1p1FR']  # , 'survey', 'payment_info'],
    },
    {
        'name': 'XP1_T1_order1',
        'display_name': "iTuna T1 Common Pool Resource Game ordre 1",
        'num_demo_participants': 3,
        'treatment':'T1',
        'app_sequence': ['XP1p1FR','XP1p2FR']    #, 'survey', 'payment_info'],
    },
    {
        'name': 'XP1_T2_order1',
        'display_name': "iTuna T2 Common Pool Resource Game ordre 1",
        'num_demo_participants': 3,
        'treatment': 'T2',
        'app_sequence': ['XP1p1FR', 'XP1p2FR']  # , 'payment_info'  # , 'survey',
    },
    {
        'name': 'XP1_T3_order1',
        'display_name': "iTuna T3 Common Pool Resource Game ordre 1",
        'num_demo_participants': 3,
        'treatment': 'T3',
        'app_sequence': ['XP1p1FR', 'XP1p2FR']  # , 'payment_info'  # , 'survey',

    },
    {
        'name': 'XP1_T1_order2',
        'display_name': "iTuna T1 Common Pool Resource Game ordre 2",
        'num_demo_participants': 3,
        'treatment': 'T1',
        'app_sequence': ['XP1p2FRorder2', 'XP1p1FRorder2']  # , 'survey', 'payment_info'],
    },
    {
        'name': 'XP1_T2_order2',
        'display_name': "iTuna T2 Common Pool Resource Game ordre 2",
        'num_demo_participants': 3,
        'treatment': 'T2',
        'app_sequence': ['XP1p2FRorder2', 'XP1p1FRorder2']  # , 'payment_info'  # , 'survey',
    },
    {
        'name': 'XP1_T3_order2',
        'display_name': "iTuna T3 Common Pool Resource Game ordre 2",
        'num_demo_participants': 3,
        'treatment': 'T3',
        'app_sequence': ['XP1p2FRorder2', 'XP1p1FRorder2']  # , 'payment_info'  # , 'survey',

    }
]

# anything you put after the below line will override
# oTree's default settings. Use with caution.
otree.settings.augment_settings(globals())
