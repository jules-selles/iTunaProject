from django import template
register = template.Library()

@register.filter(name='list_filter')
def list_filter(List, i):
    return List[0:int(i)]


