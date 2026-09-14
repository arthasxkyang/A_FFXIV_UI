"""将原 AXIS 部件缩放后的细笔画补偿至相近字重；只操作本项目已有轮廓。"""
from fontTools.pens.basePen import BasePen
from shapely.geometry import Polygon
from shapely.ops import unary_union, polygonize
from shapely import affinity

class FlattenPen(BasePen):
    def __init__(self):
        super().__init__(None);self.paths=[];self.points=[]
    def _moveTo(self,p): self.points=[p]
    def _lineTo(self,p): self.points.append(p)
    def _curveToOne(self,a,b,c):
        start=self._getCurrentPoint()
        for i in range(1,25):
            t=i/24;v=1-t
            self.points.append(tuple(v*v*v*start[k]+3*v*v*t*a[k]+3*v*t*t*b[k]+t*t*t*c[k] for k in (0,1)))
    def _closePath(self): self.paths.append(self.points);self.points=[]
    def _endPath(self): self._closePath()


def geometry(record):
    p=FlattenPen();record.replay(p);positive=[];negative=[]
    for points in p.paths:
        area=sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(points,points[1:]+points[:1]))
        shape=Polygon(points)
        if not shape.is_valid:shape=shape.buffer(0)
        (positive if area>0 else negative).append(shape)
    # 困等字有“外框—内孔—内字”三级嵌套；使用非零绕数，不能先并所有正轮廓再减孔。
    rings=positive+negative
    faces=polygonize(unary_union([shape.boundary for shape in rings]))
    return unary_union([face for face in faces
                        if sum(p.contains(face.representative_point()) for p in positive)
                        - sum(p.contains(face.representative_point()) for p in negative)>0])


def emit(shape,pen):
    from shapely.geometry.polygon import orient
    for polygon in ([shape] if shape.geom_type=='Polygon' else shape.geoms):
        if polygon.geom_type!='Polygon':continue
        polygon=orient(polygon,sign=1)
        for ring in [polygon.exterior]+list(polygon.interiors):
            points=list(ring.coords)[:-1]
            pen.moveTo(points[0])
            for point in points[1:]:pen.lineTo(point)
            pen.closePath()


def compensated_fit(record,box,pen):
    shape=geometry(record);x0,y0,x1,y1=shape.bounds
    l,t,r,b=box;sx=(r-l)/(x1-x0);sy=(b-t)/(y1-y0)
    shape=affinity.affine_transform(shape,[sx,0,0,sy,l-x0*sx,850-b-y0*sy])
    # 基准源字一的水平笔画厚88；目标以约72为主，密集小部件略减。
    weight=72*min(1,(min(r-l,b-t)/450)**.2)
    dx=max(0,(weight-82*sx)/2);dy=max(0,(weight-82*sy)/2)
    if dx>.5 or dy>.5:
        dx=max(.02,dx);dy=max(.02,dy)
        shape=affinity.scale(shape,xfact=1/dx,yfact=1/dy,origin=(0,0))
        shape=shape.buffer(1,join_style='mitre',mitre_limit=2)
        shape=affinity.scale(shape,xfact=dx,yfact=dy,origin=(0,0))
    emit(shape,pen)
