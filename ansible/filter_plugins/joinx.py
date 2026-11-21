

def joinx(arg):
    ret = arg
    if type(ret) is list:
        ret = (', ').join(arg)
    return ret


class FilterModule(object):

    def filters(self):
        return {
            'joinx': joinx
        }
