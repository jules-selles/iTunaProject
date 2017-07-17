## models.py

##-------------------------------
## Descritpion

## oTree experiment iTuna : Common Pool Resource Game

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
iTuna CPR Experiment
"""

##-------------------------------
class Constants(BaseConstants):

    ##-------------------------------
    ##Environment parameters
    xp_name = 'XPeco'
    instructions_template          = xp_name + '/instruction.html'
    functions_template             = xp_name + '/functions.html'
    profitTable_template           = xp_name + '/Profit_Table.html'
    biomassVariationTable_template = xp_name + '/Biomass_Variation_Table.html'
    scientificAssessment_template  = xp_name + '/Scientific_Assessment.html'
    projection_template            = xp_name + '/projection.html'
    endPhase_template              = xp_name + '/endPhase.html'

    convertionCurrency    = 0.05
    anticipation          = 0.2
    baseProfit            = 50
    baseProfitEuros       = 50 * convertionCurrency

    ##-------------------------------
    ## oTree parameters
    name_in_url       = 'XPeco'
    players_per_group = 3
    num_rounds        = 20

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
    init_biomass      = 52                                  # B0 [10^4 t]
    Bmsy              = carrying_capacity/2                 # MSY [10^4 t]
    Ymsy              = round((growth_rate * carrying_capacity)/4,0) # MSY [10^4 t]
    uncertainty       = 0.01 # resource level uncertainty epsilon []
    max_uncertainty   = uncertainty + (0.05 * nb_sim_years)  # projection uncertainty
    Blim              = 20  # Blim [10^3 t]
    Blim_uncertainty  = 0.4 #uncertainty range around Blim []

    ## economic parameters
    price_fish          = 10                  # p [10^7$/.1000 t]
    discount_rate       = 0                   # theta []
    theta               = 1/(1+discount_rate)
    beta                = 100                  # cost parameter [$]
    tFixedCost          = 30                   # threshold fixed cost [10^7$]
    #max_negative_profit = -50                 # limit for negative profit
    max_profit          = price_fish * carrying_capacity

    ##  global harvest choice parameters
    min_catch         = 0   # ymin [10^3 t]
    max_catch         = 5   # ymax [10^3 t]
    nb_catch_choice   = 6
    max_total_catch   = max_catch * players_per_group
    stepChoices       = (max_catch - min_catch)/(nb_catch_choice - 1)
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
    def vars_for_admin_report(self):

        group =  self.get_groups()[0]
        ## color setting
        if self.session.config['T'] == 1:
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['T'] == 2:
            colorBlim = "red"
            colorBlim_label = 'gray'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['T'] == 3:
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(213, 70, 150, 0.2)'
            colorBlim_range_label = 'gray'

        # total harvest & total profit
        totalProfit_round = []
        totalCatch_round = []
        for p in group.in_all_rounds():
            totalCatch_round.append(p.total_catch)
            totalProfit_round.append(p.total_profit)

        data = {'Total_catch': totalCatch_round, 'Total_profit': totalProfit_round,
                'Biomass': self.group.b_round,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label
                }
        seriesCatch=[]
        seriesCatch.append({'name': 'Total Catch', 'data': totalCatch_round})
        Catchseries = safe_json(seriesCatch)
        seriesProfit = []
        seriesProfit.append({'name': 'Total Profit', 'data': totalProfit_round})
        Profitseries = safe_json(seriesProfit)

        ##Biomass series
        data['seriesBiomass'] = list()
        data['seriesBmsy'] = list()
        data['seriesBlim'] = list()
        biomass = [p.b_round for p in group.in_all_rounds()]

        data['seriesBiomass'].append({'name': 'Biomass', 'data': biomass})
        data['seriesBiomass'] = safe_json(data['seriesBiomass'])
        data['seriesBmsy'] = safe_json(data['seriesBmsy'])
        data['seriesBlim'] = safe_json(data['seriesBlim'])
        data['seriesBlim_min'] = safe_json(data['seriesBlim_min'])
        data['seriesBlim_max'] = safe_json(data['seriesBlim_max'])

        return {'data': data, 'Catchseries': Catchseries, 'Profitseries': Profitseries,
                'payoff': self.participant.payoff,
                'seriesBiomass': data['seriesBiomass'],
                'seriesBmsy': data['seriesBmsy'],
                'seriesBlim': data['seriesBlim'],
                'Biomass': self.group.b_round,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label
                }

##-------------------------------
class Group(BaseGroup):

    ##--------------------------------
    ## local variables
    total_catch   = models.FloatField()
    total_profit  = models.FloatField()
    b_round       = models.FloatField()
    y             = models.FloatField()
    # Threshold and uncertainty range
    Blim_min      = models.FloatField()
    Blim_max      = models.FloatField()
    b_lim         = models.FloatField()
    # Biomass uncertainty
    bmin_round = models.FloatField()
    bmax_round = models.FloatField()
    # end
    end        = models.BooleanField(initial=False)

    ##--------------------------------
    ## standard functions

    ## ending wqhen stock collapse
    def end(self):
        self.end = True

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
        if stock <= 0:
            prof = 0
        else:
            if self.session.config['T']==1:
                    if harvestInd == 0:
                        prof = 0
                    elif stock - (harvest+harvestInd) <= 0:
                            prof = round((-Constants.beta * 2) * (prop),1)
                    else:
                            prof = round((Constants.price_fish * harvestInd) -
                                 (Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest+harvestInd))) * (prop)), 1)
            else:
                    if stock <= Constants.Blim:
                        if harvestInd == 0:
                            prof = - Constants.tFixedCost
                        elif stock - (harvest + harvestInd) <= 0:
                            prof =  round(((-Constants.beta * 2) * (prop))- Constants.tFixedCost,1)
                        else:
                            prof = round((Constants.price_fish * harvestInd) - Constants.tFixedCost -
                                 (Constants.beta * (math.log(self.growth(b=stock)) -
                                                    math.log(self.growth(b=stock) - (harvest+harvestInd))) * (prop)), 1)
                    elif stock > Constants.Blim:
                        if harvestInd == 0:
                            prof = 0
                        elif stock - (harvest + harvestInd) <= 0:
                            prof = round((-Constants.beta * 2) * (prop),1)
                        else:
                            prof = round((Constants.price_fish * harvestInd) -
                             (Constants.beta * (math.log(self.growth(b=stock)) -
                                                math.log(self.growth(b=stock) - (harvest+harvestInd)))*(prop)), 1)
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
    def set_payoffTable(self,biomasse):
        payoff_tab = [[] for _ in range(Constants.nb_catch_choice)]
        inc = -1
        for i in Constants.choice_catch:
            inc = inc + 1
            for j in Constants.other_choice_catch:
                    payoff_tab[inc].append(self.compute_payoff(harvest=j, harvestInd=i, stock=biomasse))
        return (payoff_tab)

    ## update payoff for the year by player
    def set_payoffs(self):
        if self.b_round > 0:
            self.total_catch = sum([p.catch_choice for p in self.get_players()])
            if self.subsession.round_number == 1:

                for p in self.get_players():
                    p.profit = round(self.compute_payoff(harvestInd=p.catch_choice,harvest=(self.total_catch-p.catch_choice),
                                                stock=Constants.init_biomass),1) + Constants.baseProfit
            else:

                for p in self.get_players():
                    p.profit = round(self.compute_payoff(harvestInd=p.catch_choice,harvest=(self.total_catch-p.catch_choice),
                                                   stock=self.b_round),1)
            self.total_profit = round(sum([p.profit for p in self.get_players()]),1)
            self.b_lim        = Constants.Blim

    ## update payoff and only payoff for player who best predict others harvest
    def set_payoff_prediction(self):
        for p in self.get_players():
            if self.b_round > 0:
                if p.other_choice == self.total_catch - p.catch_choice:
                    p.predProfit = p.predProfit + Constants.anticipation

    ## update biomass for the next year
    def set_biomass(self):
            bplus = models.FloatField()
            ctot  = models.FloatField()

            if self.subsession.round_number == 1:
                self.b_round = Constants.init_biomass
            elif  self.subsession.round_number == 2:
                ctot = sum([p.in_round(self.subsession.round_number - 1).catch_choice for p in self.get_players()])
                for i in self.in_previous_rounds():
                    bplus = i.b_round
                self.b_round = bplus - ctot
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
                    s = Constants.init_biomass - (i+j)
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
        if self.subsession.round_number == 1:
            for i in Constants.sim_years:
                bint = proj[i] - self.total_catch
                if i==1:
                    proj.append(bint)
                else:
                    proj.append(round(self.schaefer(bint, c=0), 0))
        else:
            for i in Constants.sim_years:
                bint = proj[i] - self.total_catch
                proj.append(round(self.schaefer(bint, c=0),0))
        return (proj)

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
        lowerUn = numpy.round(numpy.asarray(b_proj[0:Constants.nb_sim_years]) * (1 - numpy.asarray(un)[0:Constants.nb_sim_years]),1)
        range = numpy.vstack((upperUn, lowerUn)).T
        unrange.append(range.tolist())
        b_unrange.append(unrange)
        return (b_unrange)

##-------------------------------
class Player(BasePlayer):

   ##-------------------------------
   # treatment assigment variable
   TT = models.PositiveIntegerField() # treatment player variable

   # test Form variables
   growthTest     = models.PositiveIntegerField(min=0, max= 3)
   profitTest     = models.PositiveIntegerField(min=0, max=150)
   profitIndTest  = models.FloatField()
   biomassTest    = models.FloatField()

   ##-------------------------------
   ## players variables
   profit     = models.FloatField(initial=0)
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

