function pid=sistema_experto(pid,num,den,espec)

% Simulamos el modelo
  [tout,yout]=simular(pid,num,den);
    
% Calculo de las caracteristicas del sistema
  [tr,tp,Mp,ts,ys]=caracteristicas(tout,yout);
  [tout,yout]=simular(pid,num,den,tr,tp,Mp,ts,ys);
  
% Abrimos el modelo Simulink
  open_system('modelo');
  disp(' ');
  disp(' Pulse enter para ejecutar el control experto');
  pause;
  
% Incrementar o decrementar las especificaciones
  if tr<=espec(1), incrementar_tr=1; else incrementar_tr=0; end
  if tp<=espec(2), incrementar_tp=1; else incrementar_tp=0; end   
  if Mp<=espec(3), incrementar_Mp=1; else incrementar_Mp=0; end   
  if ts<=espec(4), incrementar_ts=1; else incrementar_ts=0; end   
  if ys<=espec(5), incrementar_ys=1; else incrementar_ys=0; end   
  
% Reglas del sistema experto para adaptar las caracteristicas a las especificaciones
  salir=0;
  while ~salir
       % Regla para el timepo de subida Kp
        if tr > espec(1) && (1.5 *pid(1)) < pid(3)
            pid(1)=pid(1)+(pid(1)* 0.2);    
            
        else
             pid(1)=pid(1) - (pid(1)* 0.45);
        end
        
        %Regla de la sobreelongación
         if espec(3) <= Mp
            pid(1)=pid(1)+(pid(1)* 0.08); % Subimos un poco tambien la derivativa            
            pid(3)=pid(3)+ (pid(3) * 0.75);  % Derivativa  
            pid(2)=pid(2)-(pid(2)* 0.08); % Reducir la integral
        else
            pid(3)=pid(3)- (pid(3) * 0.05);
        end 

		% Caracteristicas del sistema bajo la nueva situacion
        [tout,yout]=simular(pid,num,den,tr,tp,Mp,ts,ys);
        [tr,tp,Mp,ts,ys]=caracteristicas(tout,yout);
        
      % Si se cumplen las especificaciones, entonces salir MUY IMPORTANTE
        if tr < espec(1) && Mp < espec(3)
            salir=1;
        end
  end
  [tout,yout]=simular(pid,num,den,tr,tp,Mp,ts,ys);
  disp(' ');
  disp(' PID sintonizado, pulse enter para salir');
  pause;
  
% Cerramos el modelo Simulink
  close_system('modelo');