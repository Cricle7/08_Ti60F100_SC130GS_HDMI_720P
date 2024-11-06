import numpy as np

class PolynomialModel:
    def __init__(self):
        pass

    def calculate_output_0(self, x1, y1, x2, y2, left1, right1, up1, down1, left2, right2, up2, down2):
        output_0 = (
            6
            + -0.2676 * x2 * down1
            + -0.0097 * x2 * left2
            + -0.0278 * x2 * right2
            + 0.3441 * x2 * up2
            + -0.2643 * x2 * down2
            + -0.5189 * y2 ** 2
            + 0.1493 * y2 * left1
            + -0.0766 * y2 * right1
            + 0.4192 * y2 * up1
            + 0.0750 * y2 * down1
            + -0.0220 * y2 * left2
            + -0.0884 * y2 * right2
            + -0.0029 * y2 * up2
            + 0.0709 * y2 * down2
            + 0.1765 * left1 ** 2
            + -0.0380 * left1 * right1
            + 0.2892 * left1 * up1
            + -0.2545 * left1 * down1
            + 0.0310 * left1 * left2
            + -0.0377 * left1 * right2
            + 0.2915 * left1 * up2
            + -0.2521 * left1 * down2
            + -0.0129 * right1 ** 2
            + 0.4369 * right1 * up1
            + -0.1269 * right1 * down1
            + -0.1088 * right1 * left2
            + -0.0056 * right1 * right2
            + 0.3701 * right1 * up2
            + -0.1311 * right1 * down2
            + -1.1769 * up1 ** 2
            + 0.3178 * up1 * down1
            + 0.3350 * up1 * left2
            + 0.1686 * up1 * right2
            + -0.7554 * up1 * up2
            + 0.3201 * up1 * down2
            + 0.4198 * down1 ** 2
            + -0.4480 * down1 * left2
            + 0.2558 * down1 * right2
            + -0.3467 * down1 * up2
            + 0.4152 * down1 * down2
            + -0.1307 * left2 ** 2
            + -0.0397 * left2 * right2
            + 0.2858 * left2 * up2
            + -0.2592 * left2 * down2
            + -0.0102 * right2 ** 2
            + 0.4296 * right2 * up2
            + -0.1328 * right2 * down2
            + -1.0224 * up2 ** 2
            + 0.3065 * up2 * down2
            + 0.4094 * down2 ** 2
        )
        return output_0

    def calculate_output_1(self, x1, y1, x2, y2, left1, right1, up1, down1, left2, right2, up2, down2):
        output_1 = (
            -27.4151 * x1
            + -512.5583 * y1
            + -406.4358 * x2
            + -708.2136 * y2
            + 217.0206 * left1
            + -31.3484 * right1
            + -525.4898 * up1
            + 27.8155 * down1
            + 62.4717 * left2
            + -18.1582 * right2
            + -43.1600 * up2
            + 28.1513 * down2
            + -0.0089 * x1 ** 2
            + -0.0676 * x1 * y1
            + 0.0912 * x1 * x2
            + -0.0612 * x1 * y2
            + 0.0139 * x1 * left1
            + 0.0081 * x1 * right1
            + -0.0023 * x1 * up1
            + 0.0249 * x1 * down1
            + -0.0219 * x1 * left2
            + 0.0079 * x1 * right2
            + -0.0077 * x1 * up2
            + 0.0246 * x1 * down2
            + 0.0432 * y1 ** 2
            + 0.7566 * y1 * x2
            + -0.1661 * y1 * y2
            + -0.0349 * y1 * left1
            + 0.0180 * y1 * right1
            + 0.1333 * y1 * up1
            + -0.0211 * y1 * down1
            + -0.0508 * y1 * left2
            + 0.0161 * y1 * right2
            + 0.0518 * y1 * up2
            + -0.0220 * y1 * down2
            + -0.0195 * x2 ** 2
            + 0.4885 * x2 * y2
            + -0.1986 * x2 * left1
            + -0.0054 * x2 * right1
            + 0.1317 * x2 * up1
            + -0.0111 * x2 * down1
            + -0.0227 * x2 * left2
            + -0.0081 * x2 * right2
            + 0.0435 * x2 * up2
            + -0.0126 * x2 * down2
            + 0.5487 * y2 ** 2
            + 0.2503 * y2 * left1
            + -0.0299 * y2 * right1
            + -0.2240 * y2 * up1
            + -0.0014 * y2 * down1
            + 0.0768 * y2 * left2
            + -0.0240 * y2 * right2
            + -0.0306 * y2 * up2
            + 0.0005 * y2 * down2
            + -0.0613 * left1 ** 2
            + -0.0035 * left1 * right1
            + -0.0002 * left1 * up1
            + -0.0042 * left1 * down1
            + 0.0053 * left1 * left2
            + -0.0035 * left1 * right2
            + 0.0010 * left1 * up2
            + -0.0041 * left1 * down2
            + -0.0002 * right1 ** 2
            + 0.0647 * right1 * up1
            + -0.0136 * right1 * down1
            + -0.0173 * right1 * left2
            + -0.0017 * right1 * right2
            + 0.0534 * right1 * up2
            + -0.0143 * right1 * down2
            + 0.5182 * up1 ** 2
            + 0.0407 * up1 * down1
            + -0.2780 * up1 * left2
            + 0.0431 * up1 * right2
            + 0.1287 * up1 * up2
            + 0.0376 * up1 * down2
            + -0.0031 * down1 ** 2
            + -0.1327 * down1 * left2
            + 0.0268 * down1 * right2
            + 0.0835 * down1 * up2
            + -0.0038 * down1 * down2
            + 0.0888 * left2 ** 2
            + -0.0088 * left2 * right2
            + -0.2067 * left2 * up2
            + -0.0260 * left2 * down2
            + 0.0754 * right2 ** 2
            + -0.0949 * right2 * up2
            + -0.0295 * right2 * down2
            + 0.1822 * up2 ** 2
            + 0.0366 * up2 * down2
            + -0.0039 * down2 ** 2
        )
        return output_1

    def calculate_outputs(self, x1, y1, x2, y2, left1, right1, up1, down1, left2, right2, up2, down2):
        """同时计算 output_0 和 output_1"""
        return self.calculate_output_0(x1, y1, x2, y2, left1, right1, up1, down1, left2, right2, up2, down2), \
               self.calculate_output_1(x1, y1, x2, y2, left1, right1, up1, down1, left2, right2, up2, down2)
