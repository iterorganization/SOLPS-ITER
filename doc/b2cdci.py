"""
Generates b2cdcd.F and LaTeX output
"""
from __future__ import print_function

import xml.etree.ElementTree as etree
import textwrap


def fort_switch(name, default, category):
    pname = "'" + name + "'"
    pdefault = "'" + default + "'"
    fort = "*    {:<26} {:<22} {:<14}\n".format(pname, pdefault, category)
    return fort



def dedent(description):
    """ Removes first empty fort from description and any leading tabs
        from the next fort before the description and any following forts.
        First forts are wrapped to 70 characters.

    :param description(string): from the XML generated tooltips dictionary
    :return: formatted output for the tooltip
    """
    trim_start = 0  # Remove any leading newfort that affects dedent
    while trim_start < len(description) and description[trim_start] == '\n':
        trim_start += 1
    description = textwrap.dedent(description[trim_start:])
    lines = description.splitlines()
    output = ''
    for line in lines:
        output += '*    ' + '\n*    '.join(textwrap.wrap(line, 70)) + '\n'
    return output[0:-1]  # remove last newline

tree = etree.parse('solps-input.xml')
root = tree.getroot()
fort = ''
module = root.find('module[@name="b2mn"]')

fort += """
*    Switch name:               Default value:         Category:
*  -----------------------------------------------------------------
"""
for child in module:
    category = child.findtext('category')
    if child.tag == 'param':
        name = child.findtext('name')
        default = child.findtext('default')
        fort += fort_switch(name, default, category)
    elif child.tag == 'paramgroup':
        for param in child.findall('param'):
            name = param.findtext('name')
            default = param.findtext('default')
            fort += fort_switch(name, default, category)

fort += """*  -----------------------------------------------------------------
*
*
*
*  1. Purpose of individual parameters.
*
*   1.1. Geometry switches
"""
for child in module:
    category = child.findtext('category')
    if child.tag == 'param':
        name = child.findtext('name')
        default = child.findtext('default')
        description = child.findtext('description')
        fort += '*\n' + fort_switch(name, default, category)
        fort += dedent(description) + '\n'
    elif child.tag == 'paramgroup':
        fort += '*\n'
        description = child.findtext('description')
        for param in child.findall('param'):
            name = param.findtext('name')
            default = param.findtext('default')
            fort += fort_switch(name, default, category)
        if description is not None:
            fort += dedent(description) + '\n'

print(fort)