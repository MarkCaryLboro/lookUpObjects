classdef lookUp
    % Function and look up table abstract class
    properties ( Abstract = true )
        Xname   string                                                      % name of input(s)
        Zname   string                                                      % response name
    end
    
    properties ( SetAccess = protected, Abstract = true )
        A       double                                                      % Lower Bound for Breakpoints
        B       double                                                      % Upper Bound for Breakpoints
    end % Protected & abstract properties
    
    properties ( Access = protected,  Abstract = true )
        BP      cell                                                        % Breakpoint locations
    end % Protected and abstract properties
    
    properties ( SetAccess = protected )
        Z       double      { mustBeReal( Z ), mustBeFinite( Z ),...        % Function dependent variables
                              mustBeNumeric( Z ) }       
    end % Protected & abstract properties
    
    properties ( Constant = true, Abstract = true )
        Type    string   
    end % Constant & abstract properties
    
    properties ( SetAccess = immutable, Abstract = true )
        Nbp     int8                                                        % Number of actual breakpoints
        Name    string                                                      % Name of lookup
    end % Immutable & abstract properties  
    
    methods ( Abstract = true )
        Out = interp( obj, In );                                            % interpolate input data
        obj = setBounds( obj, A, B );                                       % set bounds for breakpoints
        obj = setBreakPoints( obj, X );                                     % set the breakpoint locations manually
        obj = setResponse( obj, Z );                                        % set the response data
        plot( obj );                                                        % plot the function or surface
    end % ordinary abstract method signatures
    
    methods ( Access = protected, Abstract = true )
        D = clipData( obj, X );                                             % clip the data to the expected range
    end
    
    methods
%         function obj = mleRegTemplate( obj, X, Y, Options )
%             %--------------------------------------------------------------
%             % Regularised MLE for model
%             %
%             % obj = obj.mleRegTemplate( X, Y, Options );
%             %
%             % Input Arguments:
%             %
%             % X         --> Input data vector
%             % Y         --> Observed response vector
%             % Options   --> Optimisation configuration object. Create with
%             %               Options = optimoptions( 'fmincon' );
%             %--------------------------------------------------------------
%             if ( nargin < 4)
%                 Options = optimoptions( 'fmincon' );
%                 Options.Display = 'Iter';
%                 Options.SpecifyObjectiveGradient = true;
%             end
%             %--------------------------------------------------------------
%             % Generate starting values if required
%             %--------------------------------------------------------------
%             X0 = obj.startingValues( X, Y );
%             %--------------------------------------------------------------
%             % Set up and execute regularised WLS PROBLEM
%             %--------------------------------------------------------------
%             C = obj.mleConstraints( X0 );
%             PROBLEM = obj.setUpMLE( X0, X, Y, W, C, NumCovPar, Options );
%             obj.Theta = fmincon( PROBLEM );
%             [ ~, ~, Lam] = feval( PROBLEM.objective, obj.Theta);
%             obj.ReEstObj = obj.ReEstObj.setLamda2Value( Lam );
%             J = obj.jacobean( X, obj.Theta );
%             Res = obj.calcResiduals( X, Y, obj.Theta );
%             obj.ReEstObj = obj.ReEstObj.calcDoF( W, J, Lam );               % Effective number of parameters
%             obj.ReEstObj = obj.ReEstObj.getMeasure( Lam, Res,...            % Calculate the performance measure
%                 W, J, NumCovPar );
%         end
    end % Ordinary methods
    
    methods
    end % Get/Set methods
    
    methods ( Access = protected )
        function [ Lo, Hi] = dataOutofBnds( obj, In )
            %--------------------------------------------------------------
            % Indicate when input data is out of bounds
            %
            % P = obj.dataOutofBnds( In );
            %
            % Input Arguments:
            %
            % In    --> Input data
            %
            % Output Arguments:
            %
            % Lo    --> Logical array indicating which data points are
            %           below the lower bound
            % Hi    --> Logical array indicating which data points are
            %           above the upper bound
            %--------------------------------------------------------------
            Hi = In > obj.B;
            Lo = In < obj.A;
        end
    end % protected methods
    
    methods ( Static = true )
    end % Static methods
end % lookUp Abstract class

