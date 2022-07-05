classdef App_code < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        TimedomainfilteroutputLabel   matlab.ui.control.Label
        InputsequenceEditField        matlab.ui.control.EditField
        InputsequenceEditFieldLabel   matlab.ui.control.Label
        OutputsequenceEditField       matlab.ui.control.EditField
        OutputsequenceEditFieldLabel  matlab.ui.control.Label
        KeypadPanel                   matlab.ui.container.Panel
        DeleteButton                  matlab.ui.control.Button
        ClearButton                   matlab.ui.control.Button
        DButton                       matlab.ui.control.Button
        Button_hash                   matlab.ui.control.Button
        Button_0                      matlab.ui.control.Button
        Button_star                   matlab.ui.control.Button
        CButton                       matlab.ui.control.Button
        Button_9                      matlab.ui.control.Button
        Button_8                      matlab.ui.control.Button
        Button_7                      matlab.ui.control.Button
        BButton                       matlab.ui.control.Button
        Button_6                      matlab.ui.control.Button
        Button_5                      matlab.ui.control.Button
        Button_4                      matlab.ui.control.Button
        AButton                       matlab.ui.control.Button
        Button_3                      matlab.ui.control.Button
        Button_2                      matlab.ui.control.Button
        Button_1                      matlab.ui.control.Button
        UIAxes_9                      matlab.ui.control.UIAxes
        UIAxes_8                      matlab.ui.control.UIAxes
        UIAxes_7                      matlab.ui.control.UIAxes
        UIAxes_6                      matlab.ui.control.UIAxes
        UIAxes_5                      matlab.ui.control.UIAxes
        UIAxes_4                      matlab.ui.control.UIAxes
        UIAxes_3                      matlab.ui.control.UIAxes
        UIAxes_2                      matlab.ui.control.UIAxes
        UIAxes                        matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
    


        function [out]=decode(app,ch,N)
            vec=[ '1' , '2' , '3' , 'A' , '4' , '5' , '6' , 'B' , '7' , '8' , '9' , 'C' , '*' , '0' , '#' , 'D' ];
            %N= 64; 
            fs= 5000;
            
            index=(vec==ch);
            
            x1=signal(vec(index),N,fs,vec); %calls the local function
            %PLOT THE SIGNAL SPECTRUM
            N_F=128;
            y1=fftshift(fft(x1,N_F));
            k=fs*(-(N_F/2):(N_F/2)-1)/N_F;
            plot(app.UIAxes_9,k,abs(y1)/N_F);
            xlabel(app.UIAxes_9,'f(Hz)')
            ylabel(app.UIAxes_9,'|X(f)|/N')
            xlim(app.UIAxes_9,[-fs/2 , fs/2]);
            title(app.UIAxes_9,"Spectrum of the signal for character: "+ch)
            
            out=bpf_bank(x1,N,fs,vec);
            
            function [h]= bpf_single(wc,fs,L)
                n= 1 :L;
                b= 1 ;
                T= 1 /fs;
                h(n)=b* cos( 2*pi*wc*n*T);
                omega = -pi:0.01:pi;
                H = freqz(h,1,omega);
                B = 1/max(abs(H));
                h = B*h;
            end
            function [x]= signal(key,N,fs,vec)
                t= 1:N;
                
                [X,Y]= meshgrid ([ 1209 1336 1477 1633 ],[ 697 770 852 941 ]);
                
                for i = 1 : 16
                    if (key==vec( i ))
                        a= 1 + fix (( i -1 )/ 4 );
                        b= 1 + rem (( i -1 ), 4 );
                    end
                end
                
                x(t)= sin (2* pi *X(a,b)*t/fs)+ sin (2*pi*Y(a,b)*t/fs);
                noise=randn(1,length(x));
                noise=((max(x)/10 )*noise)/abs(max(noise));
                x=noise+x;
            
                %plot_signal(X(a,b),Y(a,b),x,N,fs,key);
                
            end
            
                        
            function [out]= bpf_bank (x,N,fs,vec)
                wc=[ 697 770 852 941 1209 1336 1477 1633 ];
                RMStable= zeros ( 1 , 8 );
                L=100; %length of time domain impulse response of the filter
            
                h_arr= zeros(8,L);
                for i=1:8
                    h_arr(i,:)= bpf_single(wc(i),fs,L);
                end                 
                y_arr= zeros(8, N+L-1);
                
                for j = 1 : 8
                    h=h_arr(j,:);
                    y_arr(j,:) = conv(h,x); 
                    RMStable(j)=rms(y_arr(j,:));
                end
                N_FFT=N+L-1;
                
                [~, fmax_index]=sort(RMStable, 2 , 'descend' ); 
                row=min(fmax_index(:, 1 : 2 ),[], 2 );
                col=max(fmax_index(:, 1 : 2 ),[], 2 ) -4 ;                      
                out=vec( 4 *( row-1 )+col);   
            end        
        end

        function [x,fs]= signal(app,ch,fs)
            vec=[ '1' , '2' , '3' , 'A' , '4' , '5' , '6' , 'B' , '7' , '8' , '9' , 'C' , '*' , '0' , '#' , 'D' ];    
            %fs= 8000;
            t = 0:1/fs:0.2;
            
            [X,Y]= meshgrid ([ 1209 1336 1477 1633 ],[ 697 770 852 941 ]);
            
            for i = 1 : 16
                if (ch==vec( i ))
                    a= 1 + fix (( i -1 )/ 4 );
                    b= 1 + rem (( i -1 ), 4 );
                    break
                end
            end
            
            x= 0.1*(sin (2* pi *X(a,b)*t)+ sin (2*pi*Y(a,b)*t) );
            
          end
    
         function [y_arr,wc,fs]= filter_output (app,key,N)
            wc=[ 697 770 852 941 1209 1336 1477 1633 ];
            vec=[ '1' , '2' , '3' , 'A' , '4' , '5' , '6' , 'B' , '7' , '8' , '9' , 'C' , '*' , '0' , '#' , 'D' ];    
            L=100; %length of time domain impulse response of the filter
            %N=64;
            fs=5000;
            h_arr= zeros(8,L);
            for i=1:8
                h_arr(i,:)= bpf_single(wc(i),fs,L);
            end
             function [h]= bpf_single(wc,fs,L)
                n= 1 :L;
                b= 1 ;
                T= 1 /fs;
                h(n)=b* cos( 2*pi*wc*n*T);
                omega = -pi:0.01:pi;
                H = freqz(h,1,omega);
                B = 1/max(abs(H));
                h = B*h;
            end
            x=signal(key,N,fs,vec);   
            for j = 1 : 8
                h=h_arr(j,:);
                y_arr(j,:) = conv(h,x); 
                
            end
        
        
            function [x]= signal(key,N,fs,vec)
            t= 1:N;        
            [X,Y]= meshgrid ([ 1209 1336 1477 1633 ],[ 697 770 852 941 ]);
            
            for i = 1 : 16
                if (key==vec( i ))
                    a= 1 + fix (( i -1 )/ 4 );
                    b= 1 + rem (( i -1 ), 4 );
                end
            end
            x(t)= sin (2* pi *X(a,b)*t/fs)+ sin (2*pi*Y(a,b)*t/fs);
            noise=randn(1,length(x));
            noise=((max(x)/10 )*noise)/abs(max(noise));
            x=noise+x;
            end
        end


        function func1(app,key)
            fs=8000;
            N=64;

            [x,fs]=signal(app,key,fs);
            sound(x,fs);
            temp=app.InputsequenceEditField.Value;
            app.InputsequenceEditField.Value =[temp key];
            
            out=decode(app,key,N);
            temp=app.OutputsequenceEditField.Value;
            app.OutputsequenceEditField.Value =[temp out];
            plot_filter_out(app,key,N);
            %app.MainHeading.Value ="Time-domain filter output for character:"+key;
            app.TimedomainfilteroutputLabel.Text="Time-domain filter output for character:"+key;

        end
        
        function plot_filter_out(app,key,N)
        [y_arr,wc,fs]= filter_output(app,key,N);
        
        t1=(1:length(y_arr))*(1/fs);
        ax_arr=[app.UIAxes,app.UIAxes_2,app.UIAxes_3,app.UIAxes_4,app.UIAxes_5,app.UIAxes_6,app.UIAxes_7,app.UIAxes_8];
        
        %sgtitle(app.UIFigure,"Time domain filter output for key: "+key);
        for i=1:8
            y=y_arr(i,:);
            %app.UIFigure;
            
            %%subplot( 2 , 4 , i );
            plot(ax_arr(i),t1,y);
            title(ax_arr(i),"W_c="+ wc(i) +" Hz" )
            xlabel(ax_arr(i),'Time(s)');
            ylabel(ax_arr(i),'Amplitude');
            ylim(ax_arr(i),[ -1 1 ])
            xlim(ax_arr(i), [0 t1(end)])
        end
        end
            
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: Button_1
        function Button_1Pushed(app, event)
            key='1';
            func1(app,key);
        end

        % Button pushed function: Button_2
        function Button_2Pushed(app, event)
            key='2';
            func1(app,key);
        end

        % Button pushed function: Button_3
        function Button_3Pushed(app, event)
            key='3';
            func1(app,key);
        end

        % Button pushed function: AButton
        function AButtonPushed(app, event)
            key='A';
            func1(app,key);
        end

        % Button pushed function: Button_4
        function Button_4Pushed(app, event)
            key='4';
            func1(app,key);
        end

        % Button pushed function: Button_5
        function Button_5Pushed(app, event)
            key='5';
            func1(app,key);
        end

        % Button pushed function: Button_6
        function Button_6Pushed(app, event)
            key='6';
            func1(app,key);
        end

        % Button pushed function: BButton
        function BButtonPushed(app, event)
            key='B';
            func1(app,key);
        end

        % Button pushed function: Button_7
        function Button_7Pushed(app, event)
            key='7';
            func1(app,key);
        end

        % Button pushed function: Button_8
        function Button_8Pushed(app, event)
            key='8';
            func1(app,key);
        end

        % Button pushed function: Button_9
        function Button_9Pushed(app, event)
            key='9';
            func1(app,key);
        end

        % Button pushed function: CButton
        function CButtonPushed(app, event)
            key='C';
            func1(app,key);
        end

        % Button pushed function: Button_star
        function Button_starPushed(app, event)
            key='*';
            func1(app,key);
        end

        % Button pushed function: Button_0
        function Button_0Pushed(app, event)
            key='0';
            func1(app,key);
        end

        % Button pushed function: Button_hash
        function Button_hashPushed(app, event)
            key='#';
            func1(app,key);
        end

        % Button pushed function: DButton
        function DButtonPushed(app, event)
            key='D';
            func1(app,key);
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            app.InputsequenceEditField.Value ="";
            app.OutputsequenceEditField.Value ="";
            ax_arr=[app.UIAxes,app.UIAxes_2,app.UIAxes_3,app.UIAxes_4,app.UIAxes_5,app.UIAxes_6,app.UIAxes_7,app.UIAxes_8,app.UIAxes_9];
            for i=1:length(ax_arr)
                cla(ax_arr(i));
            end
        end

        % Button pushed function: DeleteButton
        function DeleteButtonPushed(app, event)
            temp=app.InputsequenceEditField.Value;
            if(length(temp)>=1)
                temp(end)='';
                app.InputsequenceEditField.Value = temp;
                app.OutputsequenceEditField.Value = temp;
            end
            

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1459 745];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [401 512 308 192];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Title')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Position = [710 512 308 192];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, 'Title')
            xlabel(app.UIAxes_3, 'X')
            ylabel(app.UIAxes_3, 'Y')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.Position = [1013 512 308 192];

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.UIFigure);
            title(app.UIAxes_4, 'Title')
            xlabel(app.UIAxes_4, 'X')
            ylabel(app.UIAxes_4, 'Y')
            zlabel(app.UIAxes_4, 'Z')
            app.UIAxes_4.Position = [401.666666666667 277 308 192];

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.UIFigure);
            title(app.UIAxes_5, 'Title')
            xlabel(app.UIAxes_5, 'X')
            ylabel(app.UIAxes_5, 'Y')
            zlabel(app.UIAxes_5, 'Z')
            app.UIAxes_5.Position = [710 277 308 192];

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.UIFigure);
            title(app.UIAxes_6, 'Title')
            xlabel(app.UIAxes_6, 'X')
            ylabel(app.UIAxes_6, 'Y')
            zlabel(app.UIAxes_6, 'Z')
            app.UIAxes_6.Position = [1016 277 308 192];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.UIFigure);
            title(app.UIAxes_7, 'Title')
            xlabel(app.UIAxes_7, 'X')
            ylabel(app.UIAxes_7, 'Y')
            zlabel(app.UIAxes_7, 'Z')
            app.UIAxes_7.Position = [710 59 308 192];

            % Create UIAxes_8
            app.UIAxes_8 = uiaxes(app.UIFigure);
            title(app.UIAxes_8, 'Title')
            xlabel(app.UIAxes_8, 'X')
            ylabel(app.UIAxes_8, 'Y')
            zlabel(app.UIAxes_8, 'Z')
            app.UIAxes_8.Position = [1016 59 308 192];

            % Create UIAxes_9
            app.UIAxes_9 = uiaxes(app.UIFigure);
            title(app.UIAxes_9, 'Title')
            xlabel(app.UIAxes_9, 'X')
            ylabel(app.UIAxes_9, 'Y')
            zlabel(app.UIAxes_9, 'Z')
            app.UIAxes_9.Position = [16 48 334 215];

            % Create KeypadPanel
            app.KeypadPanel = uipanel(app.UIFigure);
            app.KeypadPanel.Title = 'Keypad';
            app.KeypadPanel.Position = [30 308 297 311];

            % Create Button_1
            app.Button_1 = uibutton(app.KeypadPanel, 'push');
            app.Button_1.ButtonPushedFcn = createCallbackFcn(app, @Button_1Pushed, true);
            app.Button_1.Tag = 'Key1';
            app.Button_1.Position = [1 227 43 40];
            app.Button_1.Text = '1';

            % Create Button_2
            app.Button_2 = uibutton(app.KeypadPanel, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
            app.Button_2.Tag = 'Key2';
            app.Button_2.Position = [54 227 43 40];
            app.Button_2.Text = '2';

            % Create Button_3
            app.Button_3 = uibutton(app.KeypadPanel, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
            app.Button_3.Tag = 'Key3';
            app.Button_3.Position = [110 227 43 40];
            app.Button_3.Text = '3';

            % Create AButton
            app.AButton = uibutton(app.KeypadPanel, 'push');
            app.AButton.ButtonPushedFcn = createCallbackFcn(app, @AButtonPushed, true);
            app.AButton.Tag = 'KeyA';
            app.AButton.Position = [167 227 43 40];
            app.AButton.Text = 'A';

            % Create Button_4
            app.Button_4 = uibutton(app.KeypadPanel, 'push');
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @Button_4Pushed, true);
            app.Button_4.Tag = 'Key4';
            app.Button_4.Position = [1 174 43 40];
            app.Button_4.Text = '4';

            % Create Button_5
            app.Button_5 = uibutton(app.KeypadPanel, 'push');
            app.Button_5.ButtonPushedFcn = createCallbackFcn(app, @Button_5Pushed, true);
            app.Button_5.Tag = 'Key5';
            app.Button_5.Position = [54 173 43 40];
            app.Button_5.Text = '5';

            % Create Button_6
            app.Button_6 = uibutton(app.KeypadPanel, 'push');
            app.Button_6.ButtonPushedFcn = createCallbackFcn(app, @Button_6Pushed, true);
            app.Button_6.Tag = 'Key6';
            app.Button_6.Position = [110 173 43 40];
            app.Button_6.Text = '6';

            % Create BButton
            app.BButton = uibutton(app.KeypadPanel, 'push');
            app.BButton.ButtonPushedFcn = createCallbackFcn(app, @BButtonPushed, true);
            app.BButton.Tag = 'KeyB';
            app.BButton.Position = [167 173 43 40];
            app.BButton.Text = 'B';

            % Create Button_7
            app.Button_7 = uibutton(app.KeypadPanel, 'push');
            app.Button_7.ButtonPushedFcn = createCallbackFcn(app, @Button_7Pushed, true);
            app.Button_7.Tag = 'Key7';
            app.Button_7.Position = [1 121 43 40];
            app.Button_7.Text = '7';

            % Create Button_8
            app.Button_8 = uibutton(app.KeypadPanel, 'push');
            app.Button_8.ButtonPushedFcn = createCallbackFcn(app, @Button_8Pushed, true);
            app.Button_8.Tag = 'Key8';
            app.Button_8.Position = [54 121 43 40];
            app.Button_8.Text = '8';

            % Create Button_9
            app.Button_9 = uibutton(app.KeypadPanel, 'push');
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @Button_9Pushed, true);
            app.Button_9.Tag = 'Key9';
            app.Button_9.Position = [110 121 43 40];
            app.Button_9.Text = '9';

            % Create CButton
            app.CButton = uibutton(app.KeypadPanel, 'push');
            app.CButton.ButtonPushedFcn = createCallbackFcn(app, @CButtonPushed, true);
            app.CButton.Tag = 'KeyC';
            app.CButton.Position = [167 121 43 40];
            app.CButton.Text = 'C';

            % Create Button_star
            app.Button_star = uibutton(app.KeypadPanel, 'push');
            app.Button_star.ButtonPushedFcn = createCallbackFcn(app, @Button_starPushed, true);
            app.Button_star.Tag = 'Keystar';
            app.Button_star.Position = [1 65 43 40];
            app.Button_star.Text = '*';

            % Create Button_0
            app.Button_0 = uibutton(app.KeypadPanel, 'push');
            app.Button_0.ButtonPushedFcn = createCallbackFcn(app, @Button_0Pushed, true);
            app.Button_0.Tag = 'Key0';
            app.Button_0.Position = [54 65 43 40];
            app.Button_0.Text = '0';

            % Create Button_hash
            app.Button_hash = uibutton(app.KeypadPanel, 'push');
            app.Button_hash.ButtonPushedFcn = createCallbackFcn(app, @Button_hashPushed, true);
            app.Button_hash.Tag = 'Keyhash';
            app.Button_hash.Position = [110 65 43 40];
            app.Button_hash.Text = '#';

            % Create DButton
            app.DButton = uibutton(app.KeypadPanel, 'push');
            app.DButton.ButtonPushedFcn = createCallbackFcn(app, @DButtonPushed, true);
            app.DButton.Tag = 'KeyD';
            app.DButton.Position = [167 65 43 40];
            app.DButton.Text = 'D';

            % Create ClearButton
            app.ClearButton = uibutton(app.KeypadPanel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [4 22 93 36];
            app.ClearButton.Text = 'Clear';

            % Create DeleteButton
            app.DeleteButton = uibutton(app.KeypadPanel, 'push');
            app.DeleteButton.ButtonPushedFcn = createCallbackFcn(app, @DeleteButtonPushed, true);
            app.DeleteButton.Position = [110 22 102 36];
            app.DeleteButton.Text = 'Delete';

            % Create OutputsequenceEditFieldLabel
            app.OutputsequenceEditFieldLabel = uilabel(app.UIFigure);
            app.OutputsequenceEditFieldLabel.HorizontalAlignment = 'right';
            app.OutputsequenceEditFieldLabel.Position = [40 682 97 22];
            app.OutputsequenceEditFieldLabel.Text = 'Output sequence';

            % Create OutputsequenceEditField
            app.OutputsequenceEditField = uieditfield(app.UIFigure, 'text');
            app.OutputsequenceEditField.Position = [152 676 175 34];

            % Create InputsequenceEditFieldLabel
            app.InputsequenceEditFieldLabel = uilabel(app.UIFigure);
            app.InputsequenceEditFieldLabel.HorizontalAlignment = 'right';
            app.InputsequenceEditFieldLabel.Position = [49 638 87 22];
            app.InputsequenceEditFieldLabel.Text = 'Input sequence';

            % Create InputsequenceEditField
            app.InputsequenceEditField = uieditfield(app.UIFigure, 'text');
            app.InputsequenceEditField.Position = [151 632 175 34];

            % Create TimedomainfilteroutputLabel
            app.TimedomainfilteroutputLabel = uilabel(app.UIFigure);
            app.TimedomainfilteroutputLabel.FontSize = 14;
            app.TimedomainfilteroutputLabel.FontWeight = 'bold';
            app.TimedomainfilteroutputLabel.Position = [750 709 348 22];
            app.TimedomainfilteroutputLabel.Text = 'Time-domain filter output';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_code

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end