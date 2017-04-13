##views.py
##-------------------------------
## packages

from __future__ import division
import numpy
import collections
from otree.common import Currency as c, currency_range, safe_json
from django import template
from . import models
from ._builtin import Page, WaitPage
from otree.common import safe_json
from .models import Constants
register = template.Library()

##-------------------------------
class Form_WaitPage(WaitPage):

    def after_all_players_arrive(self):
        # set biomass
        self.group.set_biomass()
        # set Blim & uncertainty
        self.group.set_Un_Blim()

        ##end condition
        if self.group.b_round <= 0:
            self.group.end()

##-------------------------------
class Catch_Pledge(Page):

    timeout_seconds = 60

    def is_displayed(self):
        return self.group.b_round > 0 or self.group.end is False

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):
        var = self.group.variation()
        j = range(0,len(Constants.choice_catch))
        r = range(0,len(Constants.other_choice_catch))

        tab_payoff = self.group.set_payoffTable()
        choice = "0:%d" % (Constants.elementPayoff_Tab)

        year = self.group.year()
        name = self.player.in_round(1).name

        if self.session.config['treatment'] == 'T1':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T2':
            colorBlim = "red"
            colorBlim_label = 'gray'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T3':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(213, 70, 150, 0.2)'
            colorBlim_range_label = 'gray'

        data = {'Payoff': tab_payoff , 'round.number': self.subsession.round_number, 'biomass': self.group.b_round,
                'choicevar': choice,'variation':var,'j': j,'r': r,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'Blim_min': self.group.Blim_min,
                'Blim_max': self.group.Blim_max,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label,
                'bround': self.group.b_round,
                'MyName': name,
                'MyID': self.player.id_in_group,
                'Year': year,
                'Round':self.subsession.round_number
                }

        data['seriesBiomass'] = list()
        data['seriesBmsy'] = list()
        data['seriesBlim'] = list()
        data['seriesBlim_min'] = list()
        data['seriesBlim_max'] = list()

        biomass = [p.b_round for p in self.group.in_all_rounds()]

        data['seriesBiomass'].append({'name': 'Biomass', 'data': biomass})

        data['seriesBlim_min'].append({'name': 'Blim_min',
                                       'data': self.group.Blim_min})
        data['seriesBlim_max'].append({'name': 'Blim_max',
                                       'data': self.group.Blim_max})

        data['seriesBiomass'] = safe_json(data['seriesBiomass'])
        data['seriesBmsy'] = safe_json(data['seriesBmsy'])
        data['seriesBlim'] = safe_json(data['seriesBlim'])
        data['seriesBlim_min'] = safe_json(data['seriesBlim_min'])
        data['seriesBlim_max'] = safe_json(data['seriesBlim_max'])

        return data

    ##-------------------------------
    ## form set up
    form_model = models.Player
    form_fields = ['other_choice','catch_pledge']

##-------------------------------
class Pledge_WaitPage(WaitPage):

    def is_displayed(self):
        return self.group.b_round > 0 or self.group.end is False

    def after_all_players_arrive(self):

       return()

##-------------------------------
class Pledge_Results(Page):

    ##-------------------------------
    ## variables for template
    timeout_seconds = 30

    def is_displayed(self):
        return self.group.b_round > 0 or self.group.end is False

    def vars_for_template(self):

     name = self.player.in_round(1).name

     if self.group.b_round > 0:
        var = self.group.variation()
        j = range(0,len(Constants.choice_catch))
        r = range(0,len(Constants.other_choice_catch))

        pledge_round = []
        pledge_ID    = []
        pledge_data  = []

        for p in self.group.get_players():
            pledge_round.append(p. catch_pledge)
            pledge_ID.append(p.id_in_group)

        data = {'Player': pledge_ID, 'pledge': pledge_round}
        data = collections.OrderedDict(sorted(data.items(), key=lambda t: t[0]))

        for element, value in data.items():
            pledge_data.append(value)

        return {'data':data,'MyID':self.player.id_in_group, 'nation': pledge_data[0], 'pledge': pledge_data[1], 'variation':var, 'j': j,'r':r,
                'MyName':name}

##-------------------------------
class Catch_Choice(Page):

    timeout_seconds = 60

    def is_displayed(self):
        return self.group.b_round > 0 or self.group.end is False

    ## variables for template
    def vars_for_template(self):

        var = self.group.variation()
        j = range(0, len(Constants.choice_catch))
        r = range(0, len(Constants.other_choice_catch))
        tab_payoff = self.group.set_payoffTable()
        choice = "0:%d" % (Constants.elementPayoff_Tab)

        if self.session.config['treatment'] == 'T1':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T2':
            colorBlim = "red"
            colorBlim_label = 'gray'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T3':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(213, 70, 150, 0.2)'
            colorBlim_range_label = 'gray'

        data = {'Payoff': tab_payoff, 'round.number': self.subsession.round_number, 'biomass': self.group.b_round,
                'choicevar': choice,'variation':var, 'j': j,'r':r,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'Blim_min': self.group.Blim_min,
                'Blim_max': self.group.Blim_max,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label
                }

        data['seriesBiomass'] = list()
        data['seriesBmsy'] = list()
        data['seriesBlim'] = list()
        data['seriesBlim_min'] = list()
        data['seriesBlim_max'] = list()

        biomass = [p.b_round for p in self.group.in_all_rounds()]

        data['seriesBiomass'].append({'name': 'Biomass','data': biomass})

        data['seriesBlim_min'].append({'name': 'Blim_min',
                                       'data': self.group.Blim_min})
        data['seriesBlim_max'].append({'name': 'Blim_max',
                                       'data': self.group.Blim_max})

        data['seriesBiomass'] = safe_json(data['seriesBiomass'])
        data['seriesBmsy'] = safe_json(data['seriesBmsy'])
        data['seriesBlim'] = safe_json(data['seriesBlim'])
        data['seriesBlim_min'] = safe_json(data['seriesBlim_min'])
        data['seriesBlim_max'] = safe_json(data['seriesBlim_max'])

        return data

    ##-------------------------------
    ## form set up
    form_model = models.Player
    form_fields = ['catch_choice']

##-------------------------------
class CatchChoice_WaitPage(WaitPage):

    def after_all_players_arrive(self):
            self.group.set_payoffs()
            self.group.set_payoff_prediction()
            #if self.group.b_round > 0:
            #    self.group.projection()
            #    self.group.projUncertainty()

##-------------------------------
class Catch_Results(Page):

    timeout_seconds = 60

    def is_displayed(self):
        return self.group.b_round > 0 or self.group.end is False

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):
        # Filling the data for graph
        ##create area range series for projection uncertainty on biomass plot
        ## projection uncertainty
        proj = self.group.projection()
        proj_un = self.group.projUncertainty()

        j = -1
        UNarea = []
        seq = list(range(len(proj) + 1))

        # simplify nested list
        for i in range(1, 2):
            unArea = sum(proj_un, [])

        for row in unArea[0]:
            j = j + 1
            UNarea.append([[seq[j]] + row])

        UNarea = sum(UNarea, [])

        ## color setting
        if self.session.config['treatment'] == 'T1':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T2':
            colorBlim = "red"
            colorBlim_label = 'gray'
            colorBlim_range = 'rgba(68, 170, 213, 0)'
            colorBlim_range_label = 'rgba(68, 170, 213, 0)'
        elif self.session.config['treatment'] == 'T3':
            colorBlim = "rgba(68, 170, 213, 0)"
            colorBlim_label = 'rgba(68, 170, 213, 0)'
            colorBlim_range = 'rgba(213, 70, 150, 0.2)'
            colorBlim_range_label = 'gray'

        ## Catch, profit total and by player for each round
        catch_round      = []
        totalCatch_round = []
        totalIndCatch    = []
        profit_round     = []
        predProfit_round = []
        totalProfit_round= []
        totalIndProfit   = []
        oCatch           = []
        oProfit          = []
        oID              = []
        oData            = []
        IndHarvestEuros  = []
        IndpredEuros     = []

        # own cacth & profit per player
        for p in self.player.in_all_rounds():
            catch_round.append(p.catch_choice)
            profit_round.append(p.profit)
            predProfit_round.append(p.predProfit)
            totalIndCatch  = round(sum(catch_round),1)
            totalIndProfit = round(sum(profit_round),1)
            IndHarvestEuros= round(sum(profit_round) * Constants.convertionCurrency, 1)
            IndpredEuros = round(sum(predProfit_round), 1)

        # others cacth & profit per player
        for p in self.player.get_others_in_group():
                oCatch.append(p.catch_choice)
                oProfit.append(p.profit)
                oID.append(p.id_in_group)

        others_data = {'Player':oID, 'catch':oCatch, 'profit':oProfit}
        others_data = collections.OrderedDict(sorted(others_data .items(), key=lambda t: t[0]))

        for element, value in others_data.items():
            oData.append(value)

        # total harvest & total profit
        for p in self.group.in_all_rounds():
            totalCatch_round.append(p.total_catch)
            totalProfit_round.append(p.total_profit)

        # gather data to make series
        data = {'Player': self.player.id_in_group, 'Catch': catch_round,'Profit': profit_round,
                'TotalIndCatch':totalIndCatch,'TotalIndProfit':totalIndProfit,'payoff':self.participant.payoff,
                'Harvestpayoff':IndHarvestEuros,'Predpayoff': IndpredEuros,
                'Total_catch':  totalCatch_round, 'Total_profit':  totalProfit_round,
                'Biomass': self.group.b_round,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'Projection': proj,
                'UnRange': UNarea,
                'Blim_min': self.group.Blim_min,
                'Blim_max': self.group.Blim_max,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label
                }

        # create series to plot
        seriesCatch=[]
        seriesCatch.append({'name': 'Ma capture', 'data': catch_round})
        seriesCatch.append({'name':'Capture totale', 'data': totalCatch_round})
        Catchseries = safe_json(seriesCatch)

        seriesProfit = []
        seriesProfit.append({'name': 'Mon profit', 'data': profit_round})
        seriesProfit.append({'name': 'Profit total', 'data': totalProfit_round})
        Profitseries = safe_json(seriesProfit)

        data['seriesBiomass'] = list()
        data['seriesBmsy'] = list()
        data['seriesBlim'] = list()
        data['seriesProjection'] = list()
        data['seriesUnRange'] = list()
        data['seriesBlim_min'] = list()
        data['seriesBlim_max'] = list()

        data['seriesProjection'].append({'name': 'Projection',
                                         'data': proj})
        biomass = [p.b_round for p in self.group.in_all_rounds()]

        data['seriesBiomass'].append({'name': 'Biomass', 'data': biomass})

        data['seriesUnRange'].append({'name': 'UnRange',
                                      'data': UNarea})
        data['seriesBlim_min'].append({'name': 'Blim_min',
                                       'data': self.group.Blim_min})
        data['seriesBlim_max'].append({'name': 'Blim_max',
                                       'data': self.group.Blim_max})

        data['seriesBiomass'] = safe_json(data['seriesBiomass'])
        data['seriesBmsy'] = safe_json(data['seriesBmsy'])
        data['seriesBlim'] = safe_json(data['seriesBlim'])
        data['seriesProjection'] = safe_json(data['seriesProjection'])
        data['seriesUnRange'] = safe_json(data['seriesUnRange'])
        data['seriesBlim_min'] = safe_json(data['seriesBlim_min'])
        data['seriesBlim_max'] = safe_json(data['seriesBlim_max'])

        return {'data': data, 'Catchseries': Catchseries, 'Profitseries': Profitseries,'others_data':others_data,
                'nation': oData[0], 'catch': oData[1], 'profit': oData[2],
                'Harvestpayoff': IndHarvestEuros, 'Predpayoff': IndpredEuros,
                'TotalIndProfit': totalIndProfit,
                'payoff':self.participant.payoff,
                'seriesBiomass': data['seriesBiomass'],
                'seriesBmsy': data['seriesBmsy'],
                'seriesBlim': data['seriesBlim'],
                'seriesProjection': data['seriesProjection'],
                'seriesUnRange': data['seriesUnRange'],
                'seriesBlim_min': data['seriesBlim_min'],
                'seriesBlim_max': data['seriesBlim_max'],
                'Biomass': self.group.b_round,
                'Bmsy': Constants.Bmsy,
                'Blim': Constants.Blim,
                'Projection': proj,
                'UnRange': UNarea,
                'Bmax': self.group.bmax_round,
                'Bmin': self.group.bmin_round,
                'Blim_min': self.group.Blim_min,
                'Blim_max': self.group.Blim_max,
                'years': Constants.xp_years,
                'colorBlim': colorBlim,
                'colorBlim_range': colorBlim_range,
                'colorBlim_range_label': colorBlim_range_label,
                'colorBlim_label': colorBlim_label
                }

##-------------------------------
class End(Page):

    timeout_seconds = 30

    def vars_for_template(self):
        if self.group.b_round <= 0:
            message=' Vous avez conduit le stock à l effondrement!! ' \
                    '.... Cliquez sur l bouton next jusqu à passer en phase 2 .... '
        else:
            message='_'

        c_round    = []
        p_round    = []
        pred_round = []
        totC       = []
        totP       = []
        totPred    = []

        for p in self.player.in_all_rounds():
            c_round.append(p.catch_choice)
            p_round.append(p.profit)
            pred_round.append(p.predProfit)
            totC    = sum(c_round)
            totP    = sum(p_round )
            totPred = sum(pred_round)

        euros = round(totP * Constants.convertionCurrency,1) + totPred

        data = {'cumulatedMoney':euros,
                'profit':self.player.profit,
                'message': message}
        return (data)

    def is_displayed(self):
        return self.subsession.round_number == Constants.num_rounds or self.group.b_round <= 0

##-------------------------------
class Formend(Page):

    timeout_seconds = 120

    ##-------------------------------
    ## condition to display page
    def is_displayed(self):
        return self.subsession.round_number == Constants.num_rounds

    ##-------------------------------
    ## variables for template
    def vars_for_template(self):
        data = {}
        return data

    ##-------------------------------
    ## form set up
    form_model = models.Player

    form_fields = ['dynamicKnowledge', 'groupCooperation', 'leverageCooperation', 'suffConditionCooperation',
                       'biomassUncertainty', 'blimUncertainty']

##-------------------------------
##page sequence
page_sequence = [
    Form_WaitPage,
    Catch_Pledge,
    Pledge_WaitPage,
    Pledge_Results,
    Catch_Choice,
    CatchChoice_WaitPage,
    Catch_Results,
    End,
    Formend
]
