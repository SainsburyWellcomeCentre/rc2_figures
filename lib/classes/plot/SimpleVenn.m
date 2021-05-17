classdef SimpleVenn < RC2Axis
    
    properties
        
        A
        B
        A_and_B
        N
        
        name_A = 'A'
        name_B = 'B'
        
        radius_A
        radius_B
        target_intersect
        
        d_A
        d_B
        
        consistent
    end
    
    
    methods
        
        function obj = SimpleVenn(h_ax)
            VariableDefault('h_ax', []);
            obj = obj@RC2Axis(h_ax);
        end
        
        
        
        function val = get.radius_A(obj)
            val = sqrt(obj.A/(obj.N*pi));
        end
        
        
        
        function val = get.radius_B(obj)    
            val = sqrt(obj.B/(obj.N*pi));
        end
        
        
        function val = get.target_intersect(obj)    
            val = obj.A_and_B/obj.N;
        end
        
        
        function val = get.d_A(obj)
            
            syms x
            d = real(vpasolve(obj.intersect_area(x) == 0, x));
            val = (obj.radius_A^2 - obj.radius_B^2 + d.^2)./(2*d);
        end
        
        
        function val = get.d_B(obj)
            
            syms x
            d = real(vpasolve(obj.intersect_area(x) == 0, x));
            val = (obj.radius_B^2 - obj.radius_A^2 + d.^2)./(2*d);
        end
        
        
        function val = get.consistent(obj)
            
            val = obj.A_and_B <= obj.A & ...
                obj.A_and_B <= obj.B & ...
                obj.A <= obj.N & ...
                obj.B <= obj.N & ...
                obj.A + obj.B - obj.A_and_B <= obj.N;
        end
        
        function plot(obj)
            
            if ~obj.consistent
                error('numbers are not consistent')
            end
            
            t = 0:0.01:2*pi+0.01;
            
            x_A = -obj.d_A + obj.radius_A*cos(t);
            y_A = obj.radius_A*sin(t);
            
            x_B = obj.d_B + obj.radius_B*cos(t);
            y_B = obj.radius_B*sin(t);
            
            figure
            hold on
            plot(x_A, y_A, 'r');
            plot(x_B, y_B, 'b');
            
%             xl = get(gca, 'xlim');
%             yl = get(gca, 'ylim');
%             
%             X = range(xl);
%             Y = 1/X;
%             
%             if Y < 2*max(obj.radius_A, obj.radius_B)
%                 xl = double([(-obj.d_A - obj.radius_A), (obj.d_B + obj.radius_B)]);
%                 Y = 1/range(xl);
%             end
%             
%             xlim(xl)
%             ylim([-Y/2, Y/2])
            
            set(gca, 'dataaspectratio', [1, 1, 1], 'clipping', 'off')
%             line(xl, -Y([1, 1])/2, 'color', 'k');
%             line(xl, Y([1, 1])/2, 'color', 'k');
%             line(xl([1, 1]), [-Y/2, Y/2], 'color', 'k');
%             line(xl([2, 2]), [-Y/2, Y/2], 'color', 'k');
            axis off
            
            pAB = ((obj.d_B + obj.radius_B) + (-obj.d_A - obj.radius_A))/2;
            big_circle_x = pAB + sqrt(1/pi)*cos(t);
            big_circle_y = sqrt(1/pi)*sin(t);
            plot(big_circle_x, big_circle_y, 'k');
            
            pA = ((obj.d_B - obj.radius_B) + (-obj.d_A - obj.radius_A))/2;
            pB = ((-obj.d_A + obj.radius_A) + (obj.d_B + obj.radius_B))/2;
            pAB = ((obj.d_B - obj.radius_B) + (-obj.d_A + obj.radius_A))/2;
            
            text(pA, 0, sprintf('%s only = %i', obj.name_A, obj.A - obj.A_and_B), 'verticalalignment', 'middle', 'horizontalalignment', 'center');
            text(pB, 0, sprintf('%s only = %i', obj.name_B, obj.B - obj.A_and_B), 'verticalalignment', 'middle', 'horizontalalignment', 'center');
            text(pAB, 0, sprintf('%i', obj.A_and_B), 'verticalalignment', 'middle', 'horizontalalignment', 'center');
%             text(xl(2), Y/2, sprintf('N = %i', obj.N), 'verticalalignment', 'top', 'horizontalalignment', 'right');
            text(pAB, sqrt(1/pi), sprintf('N = %i', obj.N), 'verticalalignment', 'bottom', 'horizontalalignment', 'center');
        end
        
        
        function A = intersect_area(obj, d)
            
            rA = obj.radius_A;
            rB = obj.radius_B;
            
            dA = (rA^2 - rB^2 + d.^2)./(2*d);
            thA = acos(dA/rA);
            AA = thA*rA^2 - dA.*sqrt(rA^2 - dA.^2);
            
            dB = d - dA;
            thB = acos(dB/rB);
            AB = thB*rB^2 - dB.*sqrt(rB^2 - dB.^2);
            
            A = AA + AB - obj.target_intersect;
        end
    end
end