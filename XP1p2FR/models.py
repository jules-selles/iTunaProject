## models.py
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
## Descritpion

## oTree experiment iTuna : Common Pool Resource Game
## For a complete descirption see the document : protocole_Expérimental.docx

##-------------------------------
## Information about application

author = ' Jules Selles '

doc = """
iTuna Experiment
"""

##-------------------------------
##-------------------------------
## To do list

##-------------------------------
class Constants(BaseConstants):

    ##-------------------------------
    ##Environment variables
    xp_name                         = 'XP1p2FR'
    functions_template              = xp_name + '/functions.html'
    endSession_template             = xp_name + '/EndSession.html'
    profitTable_template            = xp_name + '/Profit_Table.html'
    biomassVariationTable_template  = xp_name + '/Biomass_Variation_Table.html'
    projection_template             = xp_name + '/projection.html'
    scientificAssessment_template   = xp_name + '/Scientific_Assessment.html'

    convertionCurrency = 0.05
    anticipation       = 0.2
    baseProfit         = 50
    baseProfitEuros    = 50 * convertionCurrency

    ##-------------------------------
    ## oTree variables
    name_in_url       = 'XP1p2FR'
    players_per_group = 3
    num_rounds        = 15

    ## global variables
    nb_sim_years       = 10
    sim_years          = list(range(0,nb_sim_years+1)) # nb of years for projection
    init_year          = 2000
    end_year           = init_year + num_rounds
    xp_years           = list(range(init_year, end_year + 1))

    ##-------------------------------
    #biologic variables
    growth_rate       = 0.15 # r []
    carrying_capacity = 70 # K [10^4 t]
    init_biomass      = 52 # B0 [10^4 t]
    Bmsy              = carrying_capacity/2   # MSY [10^4 t]
    Ymsy              = round((growth_rate * carrying_capacity)/4,0)   # MSY [10^4 t]
    uncertainty       = 0.2 # resource level uncertainty epsilon []
    max_uncertainty   = uncertainty + (0.05 * nb_sim_years)  # projection uncertainty
    Blim_un           = 20
    Blim_uncertainty  = 0.4 #uncertainty range around Blim []
    Blim_unmin        = int(Blim_un - (Blim_un*Blim_uncertainty))
    Blim_unmax        = int(Blim_un + (Blim_un*Blim_uncertainty))
    Blim              = 20 #random.choice([15,16,17,18,19,20,21,22,23,24,25])  # Blim [10^3 t]

    ##-------------------------------
    ## economic variables
    price_fish          = 10  # p [10^7$/.1000 t]
    discount_rate       = 0   # theta []
    theta               = 1 / (1 + discount_rate)
    beta                = 100  # cost parameter [10^7$/.1000 t]
    tFixedCost          = 60  # threshold fixed cost [10^7$]
    #max_negative_profit = -50 # limit for negative profit

    ##-------------------------------
    ##  harvest choice parameters
    min_catch         = 0   # ymin [10^3 t]
    max_catch         = 5  # ymax [10^3 t]
    nb_catch_choice   = 6

    max_total_catch   = nb_catch_choice * players_per_group
    stepChoices       = (max_catch - min_catch)/(nb_catch_choice - 1)
    #rowPayoff_Tab    = ((max_catch * players_per_group)/5) + 2
    elementPayoff_Tab = nb_catch_choice * ((players_per_group * nb_catch_choice)-1)

    ##-------------------------------
    ##  player harvest choice parameters
    choice_catch            = numpy.arange(min_catch, max_catch + stepChoices , stepChoices)
    tot_choice_catch        = numpy.arange(min_catch, (max_catch * players_per_group) + stepChoices , stepChoices)
    other_choice_catch      = numpy.arange(min_catch, (max_catch * (players_per_group -1)) + stepChoices , stepChoices)
    dim_other_choice_catch  = len(other_choice_catch)*2
    choice_catch            = [int(x) for x in choice_catch]
    tot_choice_catch        = [int(x) for x in tot_choice_catch]
    other_choice_catch      = [int(x) for x in other_choice_catch]

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
    ## payoff page

##-------------------------------
class Group(BaseGroup):

    ##--------------------------------
    ## local variables
    total_catch   = models.FloatField()
    total_profit  = models.FloatField()
    #payoff_tab    = [None] * Constants.nb_catch_choice * 2
    b_round       = models.FloatField()
    y             = models.FloatField()

    # Biomass uncertainty
    bmin_round    = models.FloatField()
    bmax_round    = models.FloatField()
    balea         = models.FloatField()
    b_lim         = models.FloatField()

    # Threshold and uncertainty range
    Blim_min      = models.FloatField()
    Blim_max      = models.FloatField()

    # end
    end = models.BooleanField(initial=False)

    ## projection variables and uncertainty range

    ##--------------------------------
    ## standard functions

    ## ending when stock collapse
    def end(self):
        self.end = True
        # self.subsession.round_number = Constants.num_rounds

    ## compute nb of nested list
    def number_of_lists(x):
        f = lambda x: 0 if not isinstance(x, list) else (f(x[0]) + f(x[1:]) if len(x) else 1)
        return f(x) - 1

    ## compute current year
    def year(self):
        y = Constants.init_year + self.subsession.round_number - 1
        return y

    ## compute payoff (10^7 $), profit by player see protocol
    def compute_payoff(self, harvest, harvestInd, stock):

        if (harvest + harvestInd) == 0:
            prop = 0
        else:
            prop = harvestInd / (harvest + harvestInd)

        if stock <= 0:
            prof = 0
        else:

            if self.session.config['treatment'] == 'T1':
                if self.subsession.round_number == 1:
                   prof = round((Constants.price_fish * harvestInd) -
                             (Constants.beta * (math.log(self.growth(b=Constants.init_biomass)) -
                                                math.log(self.growth(b=Constants.init_biomass) - (harvest + harvestInd))) * (prop)), 1)
                else:
                    if harvestInd == 0:
                        prof = 0
                    elif stock - (harvest + harvestInd) <= 0:
                        prof = round((-Constants.beta * 2) * (prop),1)
                    else:
                        prof = round((Constants.price_fish * harvestInd) -
                             (Constants.beta * (math.log(self.growth(b=stock)) -
                                                math.log(self.growth(b=stock) - (harvest + harvestInd))) * (prop)), 1)
            else:
                if self.subsession.round_number == 1:
                    prof = round((Constants.price_fish * harvestInd) -
                             (Constants.beta * (math.log(self.growth(b=Constants.init_biomass)) -
                                                math.log(self.growth(b=Constants.init_biomass) - (
                                                harvest + harvestInd))) * (prop)), 1)
                else:
                    if stock <= Constants.Blim:
                        if harvestInd == 0:
                            prof =  - Constants.tFixedCost
                        elif stock - (harvest + harvestInd) <= 0:
                            prof = round(((-Constants.beta * 2) * (prop))- Constants.tFixedCost,1)
                        else:
                            prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.tFixedCost + Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest + harvestInd))) * (prop)),1)
                    elif stock > Constants.Blim:
                        if harvestInd == 0:
                            prof = 0
                        elif stock - (harvest + harvestInd) <= 0:
                            prof = round((-Constants.beta * 2) * (prop),1)
                        else:
                            prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest + harvestInd))) * (prop)),1)
        return prof

    def compute_payoff_tab(self, harvest, harvestInd, stock, realStock):

        if (harvest + harvestInd) == 0:
            prop = 0
        else:
            prop = harvestInd / (harvest + harvestInd)

        if stock <= 0:
            prof = 0
        else:
            if self.session.config['treatment'] == 'T1':
                if self.subsession.round_number == 1:
                    prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=Constants.init_biomass)) -
                                                    math.log(self.growth(b=Constants.init_biomass) - (
                                                    harvest + harvestInd))) * (prop)), 1)
                else:
                    if harvestInd == 0:
                        prof = 0
                    elif stock - (harvest + harvestInd) <= 0:
                        prof = round((-Constants.beta * 2) * (prop),1)
                    else:
                        prof = round((Constants.price_fish * harvestInd) -
                                     (Constants.beta * (math.log(self.growth(b=stock)) -
                                                        math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                      prop)), 1)
            elif self.session.config['treatment'] == 'T2':
                if self.subsession.round_number == 1:
                    prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=Constants.init_biomass)) -
                                                    math.log(self.growth(b=Constants.init_biomass) - (
                                                        harvest + harvestInd))) * (prop)), 1)
                else:
                    if stock <= Constants.Blim:
                        if harvestInd == 0:
                            prof =  - Constants.tFixedCost
                        elif stock - (harvest + harvestInd) <= 0:
                            prof = round(((-Constants.beta * 2) * (prop))- Constants.tFixedCost,1)
                        else:
                            prof = round((Constants.price_fish * harvestInd) -
                                         (Constants.tFixedCost + Constants.beta * (math.log(self.growth(b=stock)) -
                                                            math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                          prop)), 1)
                    elif stock > Constants.Blim:
                        if harvestInd == 0:
                            prof = 0
                        elif stock - (harvest + harvestInd) <= 0:
                            prof = round((-Constants.beta * 2) * (prop),1)
                        else:
                            prof = round((Constants.price_fish * harvestInd) -
                                         (Constants.beta * (math.log(self.growth(b=stock)) -
                                                            math.log(self.growth(b=stock) - (harvest + harvestInd))) * (prop)), 1)
            else:
                if self.subsession.round_number == 1:
                    prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=Constants.init_biomass)) -
                                                    math.log(self.growth(b=Constants.init_biomass) - (
                                                        harvest + harvestInd))) * (prop)), 1)
                else:
                   if stock <= Constants.Blim_unmin:
                       if harvestInd == 0:
                           prof =  - Constants.tFixedCost
                       elif stock - (harvest + harvestInd) <= 0:
                           prof = round(((-Constants.beta * 2) * (prop))- Constants.tFixedCost,1)
                       else:
                            prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.tFixedCost + Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                      prop)), 1)
                   elif realStock > Constants.Blim:
                       if harvestInd == 0:
                           prof = 0
                       elif realStock - (harvest + harvestInd) <= 0:
                           prof = round((-Constants.beta * 2) * (prop),1)
                       else:
                            prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                      prop)), 1)
                   elif realStock <= Constants.Blim:
                       if harvestInd == 0:
                           prof =  - Constants.tFixedCost
                       elif realStock - (harvest + harvestInd) <= 0:
                           prof = round(((-Constants.beta * 2) * (prop)) - Constants.tFixedCost,1)
                       else:
                            prof = round((Constants.price_fish * harvestInd) -
                                         (Constants.tFixedCost + Constants.beta * (math.log(self.growth(b=stock)) -
                                                            math.log(self.growth(b=stock) - (harvest + harvestInd))) * (
                                              prop)), 1)

        return prof

    ## biomass schaefer dynamic
    def schaefer(self, b, c):
        if b <= 0:
            biomass = 0
        else:
            biomass = round(b + (Constants.growth_rate * b) * (1 - (b / Constants.carrying_capacity)) - c, 0)
            if biomass <= 0:
                biomass=0
        return biomass  # []

    ## Growth function
    def growth(self, b):
            biomass = round(b + (Constants.growth_rate * b) * (1 - (b / Constants.carrying_capacity)), 0)
            return biomass  # []

    ## biomass random variable N~(schaefer, epsilon)
    def randomB(self, mean, sd):
        if mean > 0:
            Balea= numpy.random.normal(loc=mean, scale=mean*(sd/2))
            B_min= Balea - Balea * sd
            B_max= Balea + Balea * sd
            B_un= [round(B_min,0),round(B_max,0)]
            self.balea = Balea

        Bun_data = {'Balea':round(Balea),'B_min':round(B_min), 'B_max':round(B_max),'B_un':B_un}
        return  Bun_data  # []

    ##--------------------------------
    ## upadating functions

    ## update biomass uncertainty for the next year
    def set_biomassUN(self):
        if self.subsession.round_number == 1:
            bUN = self.randomB(mean=Constants.init_biomass, sd=Constants.uncertainty)
            self.bmin_round  = bUN['B_min']
            self.bmax_round  = bUN['B_max']

        else:
            if self.b_round>0:
                bUN = self.randomB(mean=self.b_round, sd=Constants.uncertainty)
                self.bmin_round    = bUN['B_min']
                self.bmax_round    = bUN['B_max']

    ## update payoff table
            ## update payoff table

    def set_payoffTable(self):
        payoff_tab = [[] for _ in range(Constants.nb_catch_choice)]
        inc = -1
        for i in Constants.choice_catch:
            inc = inc + 1
            for j in Constants.other_choice_catch:
                #if i == 0 & j == 0:
                        payoff_tab[inc].append(self.compute_payoff_tab(harvest=j, harvestInd=i, stock=self.bmin_round, realStock=self.b_round))
                        payoff_tab[inc].append(self.compute_payoff_tab(harvest=j, harvestInd=i, stock=self.bmax_round,  realStock=self.b_round))
                #else:
                #    if (self.b_round - (j + i)) <= 0:
                #        payoff_tab[inc].append(Constants.max_negative_profit)
                #        payoff_tab[inc].append(Constants.max_negative_profit)
                #    else:
                #      payoff_tab[inc].append(self.compute_payoff(harvest=j, harvestInd=i, stock=self.bmin_round))
                #      payoff_tab[inc].append(self.compute_payoff(harvest=j, harvestInd=i, stock=self.bmax_round))

        return (payoff_tab)

        ## update payoff for the year by player
    def set_payoffs(self):

        if self.b_round > 0:
            self.total_catch = sum([p.catch_choice for p in self.get_players()])

            if self.subsession.round_number == 1:
                for p in self.get_players():
                    p.profit = round(self.compute_payoff(harvestInd=p.catch_choice,
                                                   harvest=(self.total_catch - p.catch_choice),
                                                   stock=Constants.init_biomass),1) + Constants.baseProfit
                    p.payoff = round((self.compute_payoff(harvestInd=p.catch_choice,
                                                   harvest=(self.total_catch - p.catch_choice),
                                                   stock=Constants.init_biomass) + Constants.baseProfit )* Constants.convertionCurrency,1)
            else:
                for p in self.get_players():
                    p.profit = round(self.compute_payoff(harvestInd=p.catch_choice,
                                                   harvest=(self.total_catch - p.catch_choice),
                                                   stock=self.b_round),1)
                    p.payoff = round(self.compute_payoff(harvestInd=p.catch_choice,
                                                   harvest=(self.total_catch - p.catch_choice),
                                                   stock=self.b_round) * Constants.convertionCurrency,1)

            self.total_profit = round(sum([p.profit for p in self.get_players()]),1)
            self.b_lim = Constants.Blim

    ## update payoff and only payoff for player who best predict others harvest
    def set_payoff_prediction(self):
        for p in self.get_players():
            if self.b_round > 0:
                if p.other_choice == self.total_catch - p.catch_choice:
                    p.payoff = p.payoff + Constants.anticipation
                    p.predProfit = p.predProfit + Constants.anticipation

    ## update biomass for the next year
    def set_biomass(self):

        bplus = models.FloatField()
        ctot  = models.FloatField()

        if self.subsession.round_number == 1:
            self.b_round = Constants.init_biomass

        elif self.subsession.round_number == 2:
            ctot = sum([p.in_round(self.subsession.round_number - 1).catch_choice for p in self.get_players()])
            for i in self.in_previous_rounds():
                bplus = i.b_round
            self.b_round = bplus - ctot

        else:
            ctot  = sum([p.in_round(self.subsession.round_number - 1).catch_choice for p in self.get_players()])

            for i in self.in_previous_rounds():
                bplus = i.b_round

            self.b_round = self.schaefer(b=bplus, c=ctot)

    ##-----------------------------
    ## scientific advice

    ## function uncertainty around Blim for all rounds
    def set_Un_Blim(self):
        if self.b_round>0:
        # uncertainty bounds around Blim
            self.Blim_max = Constants.Blim_un + (Constants.Blim_un * Constants.Blim_uncertainty)
            self.Blim_min = Constants.Blim_un - (Constants.Blim_un * Constants.Blim_uncertainty)

    ## function variation for each catch level
    def variation(self):
        var = [[] for _ in range(Constants.nb_catch_choice)]
        s1   = models.FloatField()
        s2   = models.FloatField()
        inc = -1

        if self.subsession.round_number == 1:
            for i in Constants.choice_catch:
                inc = inc + 1
                for j in Constants.other_choice_catch:
                    s1 = self.bmin_round - (i + j)
                    var[inc].append(round(((s1 - self.bmin_round) / self.bmin_round) * 100))
                    s2 = self.bmax_round - (i + j)
                    var[inc].append(round(((s2 - self.bmax_round) / self.bmax_round) * 100))
        else:
            for i in Constants.choice_catch:
                inc = inc + 1
                for j in Constants.other_choice_catch:
                    s1 = self.schaefer(b=self.bmin_round, c=(i + j))
                    var[inc].append(round(((s1 - self.bmin_round) / self.bmin_round)*100))
                    s2 = self.schaefer(b=self.bmax_round, c=(i + j))
                    var[inc].append(round(((s2 - self.bmax_round) / self.bmax_round)*100))

        return(var)

    ## function projection for 10 years
    def projection(self):
        proj = []
        bint = models.FloatField()
        #proj.append(self.b_round)
        proj.append(self.balea)

        if self.subsession.round_number == 1:
            for i in Constants.sim_years:
                bint = proj[i] - self.total_catch
                if i == 1:
                    proj.append(bint)
                else:
                    proj.append(round(self.schaefer(bint, c=0), 0))
        else:
            for i in Constants.sim_years:
                bint = proj[i] - self.total_catch
                proj.append(round(self.schaefer(bint, c=0),0))
        return(proj)

    ## function uncertainty around projection for 10 years

    def projUncertainty(self):
        unrange   = []
        b_unrange = []
        un        = []
        upUN      = []
        lwUN      = []
        b_proj    = self.projection()

        # uncertainty bounds around real projection
        for meanNorm in arange(Constants.uncertainty, Constants.max_uncertainty,
                               (Constants.max_uncertainty - Constants.uncertainty) / (len(Constants.sim_years))):
            un.append(numpy.random.normal(loc=meanNorm, scale=meanNorm *(Constants.uncertainty/2)))

        upperUn = numpy.round(numpy.asarray(b_proj[0:11]) * (1 + numpy.asarray(un)[0:11]),1)
        upUN.append([int(x) for x in upperUn])

        lowerUn = numpy.round(numpy.asarray(b_proj[0:11]) * (1 - numpy.asarray(un)[0:11]),1)
        lwUN.append([int(x) for x in lowerUn])

        range = numpy.vstack((upperUn, lowerUn)).T
        unrange.append(range.tolist())
        b_unrange.append(unrange)

        return(b_unrange)

##-------------------------------
class Player(BasePlayer):

   ##-------------------------------
   # treatment assigment variable
   TT = models.CharField() # treatment player variable

   # test Form variables
   growthTest    = models.PositiveIntegerField(min=0, max=3)
   profitTest    = models.PositiveIntegerField(min=0, max=150)
   profitIndTest = models.FloatField()
   biomassTest   = models.PositiveIntegerField()

   ##-------------------------------
   # 1st Form variables
   name = models.CharField()
   profession = models.CharField()
   age = models.PositiveIntegerField()
   playAs = models.CharField(
       choices=["Pêcheur", "Gestionnaire dans le domaine de l'halieutique",
                "Scientifique dans le domaine de l'halieutique",
                "Scientifique (autre)", "Etudiant dans le domaine de l'halieutique", "Etudiant (autre)", "Autre"])
   # 2nd Form variables
   dynamicKnowledge = models.CharField(
       choices=["Complètement d'accord", "D'accord", "Ni d'accord, ni pas d'accord",
                "pas d'accord", "Complètement pas d'accord"])
   groupCooperation = models.CharField(
       choices=["Complètement d'accord", "D'accord", "Ni d'accord, ni pas d'accord",
                "pas d'accord", "Complètement pas d'accord"])
   leverageCooperation = models.CharField(
       choices=["Analyse du tableau des profits", "Analyse des propositions", "Analyse du niveau de biomasse",
                "Analyse du niveau de capture et de profit des autres participants"])
   suffConditionCooperation = models.CharField(
       choices=["Complètement d'accord", "D'accord", "Ni d'accord, ni pas d'accord",
                "pas d'accord", "Complètement pas d'accord"])
   biomassUncertainty = models.CharField(
       choices=["Complètement d'accord", "D'accord", "Ni d'accord, ni pas d'accord",
                "pas d'accord", "Complètement pas d'accord"])

   blimUncertainty = models.CharField(
       choices=["Complètement d'accord", "D'accord", "Ni d'accord, ni pas d'accord",
                "pas d'accord", "Complètement pas d'accord","Pas dans mon traitement"])

   ##-------------------------------
   ## players variables
   profit       = models.FloatField()
   predProfit = models.FloatField(initial=0)

   ## player etimation other harvesting level
   other_choice = models.PositiveIntegerField(
       choices=Constants.other_choice_catch,initial=0)

   ## player harvest choice
   catch_choice = models.PositiveIntegerField(
            choices=Constants.choice_catch,initial=0)

   ## player proposal harvest choice
   catch_pledge = models.PositiveIntegerField(
       choices=Constants.choice_catch,initial=0)
