% 
%no smallest number of points required
%k number of iterations
%t threshold used to id a point that fits well
%d number of nearby points required
 
 
function [p_best,n_best,ro_best,X_best,Y_best,Z_best,error_best]=ransac_tim(p,no,k,t,d)
 
%Initialize variables
iterations=0;
%Until k iterations have occurrec
while iterations < k
    ii=0;
    clear p_close dist p_new p_in p_out
 
    %Draw a sample of n points from the data
    perm=randperm(length(p));
    sample_in=perm(1:no);
    p_in=p(sample_in,:);
    sample_out=perm(no+1:end);
    p_out=p(sample_out,:);
 
    %Fit to that set of n points
    [n_est_in ro_est_in]=LSE(p_in);
 
    %For each data point oustide the sample
    for i=sample_out
        dist=dot(n_est_in,p(i,:))-ro_est_in;
        %Test distance d to t
        abs(dist);
        if abs(dist)<t %If d<t, the point is close
            ii=ii+1;
            p_close(ii,:)=p(i,:);
        end
    end
 
    p_new=[p_in;p_close];
 
    %If there are d or more points close to the line
    if length(p_new) > d
        %Refit the line using all these points
        [n_est_new ro_est_new X Y Z]=LSE(p_new);
        for iii=1:length(p_new)
            dist(iii)=dot(n_est_new,p_new(iii,:))-ro_est_new;
        end
        %Use the fitting error as error criterion (ive used SAD for ease)
        error(iterations+1)=sum(abs(dist));
    else
        error(iterations+1)=inf;
    end
 
 
    if iterations >1
        %Use the best fit from this collection 
        if error(iterations+1) <= min(error)
            p_best=p_new;
            n_best=n_est_new;
            ro_best=ro_est_new;
            X_best=X;
            Y_best=Y;
            Z_best=Z;
            error_best=error(iterations+1);
        end
    end
 
    iterations=iterations+1;
end
 
 
end

function [n_est ro_est X Y Z]=LSE(p)
%© Tim Zaman 2010, input: p (points)
% Works like [n_est ro_est X Y Z]=LSE(p)
% p should be a Mx3; [points x [X Y Z]]</code>
 
%Calculate mean of all points
pbar=mean(p);
for i=1:length(p)
A(:,:,i)=(p(i,:)-pbar)'*(p(i,:)-pbar);
end
 
%Sum up all entries in A
Asum=sum(A,3);
[V ~]=eig(Asum);
 
%Calculate new normal vector
n_est=V(:,1);
 
%Calculate new ro
ro_est=dot(n_est,pbar);
 
[X,Y]=meshgrid(min(p(:,1)):max(p(:,1)),min(p(:,2)):max(p(:,2)));
Z=(ro_est-n_est(1)*X-n_est(2).*Y)/n_est(3);
end