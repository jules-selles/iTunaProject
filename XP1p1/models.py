## models.py

##-------------------------------
## Descritpion

## oTree experiment iTuna : Common Pool Resource Game
## For a complete descirption see the document : protocole_Expérimental.docx

##-------------------------------
## packages
from __future__ import division
import random
import math
import numpy
from numpy import arange
from numpy import asarray
from numpy import vstack
import otree.models
from otree.db import models
from otree import widgets
from otree.common import Currency as c, currency_range, safe_json
from otree.constants import BaseConstants
from otree.models import BaseSubsession, BaseGroup, BasePlayer
from django import template
register = template.Library()

##-------------------------------
## Information about application

author = ' Jules Selles '

doc = """
iTuna Experiment
"""

##-------------------------------
##-------------------------------
## To do list

##Buggs priority 1
##-> demo mode
##-> postgreSql

##Buggs priority 2
## -> !! projection in phase 2 et 3 pour s'adapter au range uncertainty of Biomass

## Basics
## -> test player's understanding before start
## -> find a way to don't copy 3 times apps to create each phase of XP

##-------------------------------
class Constants(BaseConstants):

    ##-------------------------------
    ##Environment parameters
    xp_name = 'XP1p1'
    instructions_template          = xp_name + '/instruction.html'
    functions_template             = xp_name + '/functions.html'
    profitTable_template           = xp_name + '/Profit_Table.html'
    biomassVariationTable_template =  xp_name + '/Biomass_Variation_Table.html'
    scientificAssessment_template  =  xp_name + '/Scientific_Assessment.html'
    projection_template            =  xp_name + '/projection.html'
    endPhase_template              = xp_name + '/endPhase.html'

    convertionCurrency    = 0.035

    ##-------------------------------
    ## oTree parameters
    name_in_url       = 'XP1p1'  #
    players_per_group = 3
    num_rounds        = random.choice([15])  # !! random value to put into before session in subsession

    ##-------------------------------
    ## Model parameters

    ## global parameters
    nb_sim_years      = 10
    sim_years         = list(range(0,nb_sim_years+1)) # nb of years for projection
    init_year         = 2000
    end_year          = init_year + num_rounds
    xp_years          = list(range(init_year, end_year + 1))

    # biologic parameters
    growth_rate       = 0.15                                # r []
    carrying_capacity = 70                                  # K [10^4 t]
    init_biomass      = 50                                  # B0 [10^4 t]
    Bmsy              = carrying_capacity/2                 # MSY [10^4 t]
    Ymsy              = round((growth_rate * carrying_capacity)/4,0) # MSY [10^4 t]
    uncertainty       = 0.01 # resource level uncertainty epsilon []
    max_uncertainty   = uncertainty + (0.05 * nb_sim_years)  # projection uncertainty
    Blim              = 20  # Blim [10^3 t]
    Blim_uncertainty  = 0.4 #uncertainty range around Blim []

    ## economic paramyeters
    price_fish          = 10                  # p [10^7$/.1000 t]
    discount_rate       = 0                   # theta []
    theta               = 1/(1+discount_rate)
    beta                = 100                  # cost parameter [$]
    tFixedCost          = 20                   # threshold fixed cost [10^7$]
    max_negative_profit = -50                  # limit for negative profit
    max_profit          = price_fish * carrying_capacity

    ##  global harvest choice parameters
    min_catch         = 0   # ymin [10^3 t]
    max_catch         = 5   # ymax [10^3 t]
    nb_catch_choice   = 6
    max_total_catch   = max_catch * players_per_group
    stepChoices       = (max_catch - min_catch)/(nb_catch_choice - 1)
    #rowPayoff_Tab     = ((max_catch * players_per_group)/5) + 2
    elementPayoff_Tab = nb_catch_choice * ((players_per_group * nb_catch_choice)-1)

    ##  player harvest choice parameters
    choice_catch            = numpy.arange(min_catch, max_catch + stepChoices , stepChoices)
    tot_choice_catch        = numpy.arange(min_catch, (max_catch * players_per_group) + stepChoices , stepChoices)
    other_choice_catch      = numpy.arange(min_catch, (max_catch * (players_per_group -1)) + stepChoices , stepChoices)
    dim_other_choice_catch  = len(other_choice_catch)
    choice_catch            = [int(x) for x in choice_catch]
    tot_choice_catch        = [int(x) for x in tot_choice_catch]
    other_choice_catch      = [int(x) for x in other_choice_catch]

    ## test parameters
    b_test     = 25
    c_test     = 9
    c_ind_test = c_test / players_per_group
##-------------------------------
class Subsession(BaseSubsession):

    ##-------------------------------
    ## random assigment to treatment
    def before_session_starts(self):

        if self.round_number == 1:
            for p in self.get_players():
                if 'treatment' in self.session.config:
                     # demo mode
                     p.participant.vars['TT'] = self.session.config['treatment']
                else:
                     p.participant.vars['TT'] = random.choice(['T1','T2','T3'])

    ##-------------------------------
    ## phase organisation

##-------------------------------
class Group(BaseGroup):

    ##--------------------------------
    ## local variables
    total_catch   = models.FloatField()
    total_profit  = models.FloatField()
    #payoff_tab   = [None] * Constants.nb_catch_choice
    b_round       = models.FloatField()
    y             = models.FloatField()

    # Threshold and uncertainty range
    Blim_min      = models.FloatField()
    Blim_max      = models.FloatField()
    # Biomass uncertainty
    bmin_round = models.FloatField()
    bmax_round = models.FloatField()

    # end
    end           = models.BooleanField(initial=False)

    ## projection variables and uncertainty range

    ##--------------------------------
    ## standard functions

    ## ending wqhen stock collapse
    def end(self):
        self.end = True
        #self.subsession.round_number = Constants.num_rounds

    ## compute nb of nested list
    def number_of_lists(x):
        f = lambda x: 0 if not isinstance(x, list) else (f(x[0]) + f(x[1:]) if len(x) else 1)
        return f(x) - 1

    ## compute current year
    def year(self):
        y = Constants.init_year + self.subsession.round_number - 1
        return y

    ## compute payoff (10^3 $), profit by player see protocol
    def compute_payoff(self , stock, harvest=0, harvestInd=0):

        if (harvest+harvestInd) == 0:
            prop=0
        else:
            prop=harvestInd/(harvest+harvestInd)

        if self.session.config['treatment']=='T1':
                if self.subsession.round_number == 1:
                    prof = round((Constants.price_fish * harvestInd) -
                             (Constants.beta *(math.log(self.growth(b=Constants.init_biomass)) -
                                               math.log(self.growth(b=Constants.init_biomass) - (harvest+harvestInd)))*(prop)),1)

                else:
                    if stock - (harvest + harvestInd) <= 0:
                        prof = -Constants.beta
                    else:
                        prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest+harvestInd))) * (prop)), 1)
        else:
                if self.subsession.round_number == 1:
                    prof = round((Constants.price_fish * harvestInd) -
                             (Constants.beta * (math.log(self.growth(b=Constants.init_biomass)) -
                                                math.log(self.growth(b=Constants.init_biomass) - (harvest+harvestInd)))*(prop)), 1)
                else:
                    if stock - (harvest + harvestInd) <= 0:
                        prof = -Constants.beta
                    else:
                        if stock <= Constants.Blim:
                            prof = round((Constants.price_fish * harvestInd) - Constants.tFixedCost -
                                 (Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest+harvestInd))) * (prop)), 1)
                        if stock > Constants.Blim:
                            prof = round((Constants.price_fish * harvestInd) -
                             (Constants.beta * (math.log(self.growth(b=stock)) -
                                                math.log(self.growth(b=stock) - (harvest+harvestInd)))*(prop)), 1)

        return prof

    def compute_payoff_test(self, stock, harvest=0, harvestInd=0):

        if (harvest + harvestInd) == 0:
            prop = 0
        else:
            prop = harvestInd / (harvest + harvestInd)

        if self.session.config['treatment'] == 'T1':
            if stock - (harvest + harvestInd) <= 0:
                prof = -Constants.beta
            else:
                prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest + harvestInd))) * (prop)),1)
        else:
            if stock - (harvest + harvestInd) <= 0:
                prof = -Constants.beta
            else:
                    if stock <= Constants.Blim:
                        prof = round((Constants.price_fish * harvestInd) - Constants.tFixedCost -
                                     (Constants.beta * (math.log(self.growth(b=stock)) -
                                                        math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                      prop)), 1)
                    if stock > Constants.Blim:
                        prof = round((Constants.price_fish * harvestInd) -
                                     (Constants.beta * (math.log(self.growth(b=stock)) -
                                                        math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                      prop)), 1)

        return prof

    ## biomass schaefer dynamic
    def schaefer(self, b, c=0):
        if b <= 0:
            biomass = 0
        else:
            biomass = round(b + (Constants.growth_rate * b) * (1 - (b / Constants.carrying_capacity)) - c, 0)

        return biomass  # []

    ## Growth function
    def growth(self, b):
        biomass = round(b + (Constants.growth_rate * b) * (1 - (b / Constants.carrying_capacity)) , 0)

        return biomass  # []

    ##--------------------------------
    ## upadating functions

    ## update payoff table
    def set_payoffTable(self):
        payoff_tab = [[] for _ in range(Constants.nb_catch_choice)]
        inc = -1
        for i in Constants.choice_catch:
            inc = inc + 1
            for j in Constants.other_choice_catch:
                if i == 0 & j == 0:
                    payoff_tab[inc].append(self.compute_payoff(harvest=j, harvestInd=i, stock=self.b_round))
                else:
                    if (self.b_round - (j + i)) <= 0:
                        payoff_tab[inc].append(Constants.max_negative_profit)
                    else:
                        payoff_tab[inc].append(self.compute_payoff(harvest=j, harvestInd=i, stock=self.b_round))

        return (payoff_tab)

    def set_payoffTable_test(self,biomasse=Constants.b_test):
        payoff_tab = [[] for _ in range(Constants.nb_catch_choice)]
        inc = -1
        for i in Constants.choice_catch:
            inc = inc + 1
            for j in Constants.other_choice_catch:
                if i == 0 & j == 0:
                    payoff_tab[inc].append(self.compute_payoff_test(harvest=j, harvestInd=i, stock=biomasse))
                else:
                    if (biomasse - (j + i)) <= 0:
                        payoff_tab[inc].append(Constants.max_negative_profit)
                    else:
                        payoff_tab[inc].append(self.compute_payoff_test(harvest=j, harvestInd=i, stock=biomasse))

        return (payoff_tab)

    ## update payoff for the year by player
    def set_payoffs(self):
         self.total_catch = sum([p.catch_choice for p in self.get_players()])

         if self.subsession.round_number == 1:

             for p in self.get_players():
                 p.profit = round(self.compute_payoff(harvestInd=p.catch_choice,harvest=(self.total_catch-p.catch_choice),
                                                stock=Constants.init_biomass),1)
                 p.payoff = round(self.compute_payoff(harvestInd=p.catch_choice,harvest=(self.total_catch-p.catch_choice),
                                                stock=Constants.init_biomass)* Constants.convertionCurrency,1)
         else:

             for p in self.get_players():
                p.profit = round(self.compute_payoff(harvestInd=p.catch_choice,harvest=(self.total_catch-p.catch_choice),
                                               stock=self.b_round),1)
                p.payoff = round(self.compute_payoff(harvestInd=p.catch_choice, harvest=(self.total_catch - p.catch_choice),
                                               stock=self.b_round) * Constants.convertionCurrency,1)

         self.total_profit = round(sum([p.profit for p in self.get_players()]),1)

    ## update biomass for the next year
    def set_biomass(self):

        bplus = models.FloatField()
        ctot  = models.FloatField()

        if self.subsession.round_number == 1:
            self.b_round = Constants.init_biomass
        else:
            ctot  = sum([p.in_round(self.subsession.round_number -1).catch_choice for p in self.get_players()])

            for i in self.in_previous_rounds():
                bplus = i.b_round

            self.b_round = self.schaefer(b=bplus, c=ctot)

    ##--------------------------------
    ## scientific advice

    ## function uncertainty around Blim for all rounds
    def set_Un_Blim(self):
        # uncertainty bounds around Blim
        self.Blim_max = Constants.Blim + (Constants.Blim * Constants.Blim_uncertainty)
        self.Blim_min = Constants.Blim - (Constants.Blim * Constants.Blim_uncertainty)

    ## function variation for each catch level
    def variation(self):
        var = [[] for _ in range(Constants.nb_catch_choice)]
        s   = models.FloatField()
        inc = -1

        if self.subsession.round_number == 1:
            for i in Constants.choice_catch:
                inc = inc +1
                for j in Constants.other_choice_catch:
                    s = self.schaefer( b=Constants.init_biomass, c=(i+j))
                    var[inc].append(round(((s - Constants.init_biomass)/Constants.init_biomass)*100))

        else:
            for i in Constants.choice_catch:
                inc = inc + 1
                for j in Constants.other_choice_catch:
                    s = self.schaefer( b=self.b_round, c=(i + j))
                    var[inc].append(round(((s - self.b_round) / self.b_round)*100))

        return(var)

    ## function projection for 10 years
    def projection(self):
        proj = []
        bint = models.FloatField()

        proj.append(self.b_round)
        for i in Constants.sim_years:
            bint = proj[i] - self.total_catch
            proj.append(round(self.schaefer(bint, c=0),0))
        return (proj)

    ## function uncertainty around projection for 10 years
    ##!!!!!!!!! attention pb correspondance avec l'incertitude sur le stock!!

    def projUncertainty(self):
        unrange = []
        b_range = []
        b_unrange = []
        un = []
        b_proj = self.projection()

        # uncertainty bounds around real projection
        for meanNorm in arange(Constants.uncertainty, Constants.max_uncertainty,
                               (Constants.max_uncertainty - Constants.uncertainty) / (len(Constants.sim_years))):
            un.append(numpy.random.normal(loc=round(meanNorm,3), scale=round(meanNorm,3) / 10))

        upperUn = numpy.round(numpy.asarray(b_proj[0:Constants.nb_sim_years]) * (1 + numpy.asarray(un)[0:Constants.nb_sim_years]),1)
       # upUN.append([int(x) for x in upperUn])

        lowerUn = numpy.round(numpy.asarray(b_proj[0:Constants.nb_sim_years]) * (1 - numpy.asarray(un)[0:Constants.nb_sim_years]),1)
        #lwUN.append([int(x) for x in lowerUn])
        range = numpy.vstack((upperUn, lowerUn)).T
        unrange.append(range.tolist())
        b_unrange.append(unrange)

        return (b_unrange)

##-------------------------------
class Player(BasePlayer):

   ##-------------------------------
   # treatment assigment variable
   TT = models.CharField() # treatment player variable

   ##-------------------------------
   # 1st Form variables
   name       = models.CharField()
   profession = models.CharField()
   age        = models.PositiveIntegerField()
   playAs     =  models.CharField(
       choices=["General audience", "Fisherman", "Manager", "Scientist in the field of fisheries",
                "Scientist (other)","Student in the field of fisheries", "Student (other)"])

   # test Form variables
   growthTest     = models.PositiveIntegerField(min=0, max= 3)
   profitTest     = models.PositiveIntegerField(min=-50, max=150)
   biomassTest    = models.PositiveIntegerField(min=0, max=70)

   ##-------------------------------
   ## players variables
   profit = models.FloatField()

   ## player etimation other harvesting level
   other_choice = models.PositiveIntegerField(
       choices=Constants.other_choice_catch,initial=0)

   ## player harvest choice
   catch_choice = models.PositiveIntegerField(
            choices=Constants.choice_catch,initial=0)

   ## player proposal harvest choice
   catch_pledge = models.PositiveIntegerField(
       choices=Constants.choice_catch,initial=0)

