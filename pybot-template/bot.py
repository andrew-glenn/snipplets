#!/usr/bin/env python

import sys, os, re, threading, imp

home = os.getcwd()

class Bobs(object):
    def __init__(self):
        self.setup()    
    
    def setup(self):
        self.variables = {}
        modules = []        
        filenames = []


        for fn in os.listdir(os.path.join(home, 'modules')):
            if fn.endswith('.py') and not fn.startswith('_'):
                filenames.append(os.path.join(home, 'modules', fn))
        for fname in filenames: 
            name = os.path.basename(fname)[:-3]
            try:
                module = imp.load_source(name, fname)
            except Exception, e:
                print "Error loading %s %s (in bot.py)" %(name, e)
            else:
                self.register(vars(module))
                modules.append(name)

        if modules:
            print 'Registered modules: ',', '.join(modules)
        else: print "Couldn't find any modules"

    def register(self, variables):
        for name, obj in variables.iteritems():
            if hasattr(obj, 'commands'):
                self.variables[name] = obj

    def parser(self, command):
        # Is the command bound? 
        if command in self.variables:
            self.variables[command]()
        else:
            print "Sorry, %s isn't a bound command." %(command)


